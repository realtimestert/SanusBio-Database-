require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const cors = require('cors');
const { body, validationResult } = require('express-validator');
const path = require('path');
const fs = require('fs').promises;
const webPush = require('web-push');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Database connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'sanusbio',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Web Push setup (for notifications)
const vapidKeys = {
  publicKey: process.env.VAPID_PUBLIC_KEY || 'YOUR_PUBLIC_KEY',
  privateKey: process.env.VAPID_PRIVATE_KEY || 'YOUR_PRIVATE_KEY'
};
webPush.setVapidDetails(
  'mailto:admin@sanusbio.com',
  vapidKeys.publicKey,
  vapidKeys.privateKey
);

// File upload configuration
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const dir = 'uploads/ferrets';
    await fs.mkdir(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'ferret-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only image files are allowed'));
  }
});

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Role-based authorization middleware
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};

// ==================== AUTH ROUTES ====================

// Register new user (admin only)
app.post('/api/auth/register', 
  authenticateToken,
  authorize('admin'),
  [
    body('username').trim().isLength({ min: 3 }),
    body('password').isLength({ min: 6 }),
    body('email').isEmail(),
    body('role').isIn(['admin', 'research', 'maternity', 'caretaker'])
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { username, password, email, role, full_name } = req.body;

      // Check if user exists
      const [existing] = await pool.query(
        'SELECT user_id FROM users WHERE username = ? OR email = ?',
        [username, email]
      );

      if (existing.length > 0) {
        return res.status(400).json({ error: 'Username or email already exists' });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert user
      const [result] = await pool.query(
        'INSERT INTO users (username, password, email, role, full_name, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
        [username, hashedPassword, email, role, full_name]
      );

      res.status(201).json({
        message: 'User created successfully',
        user_id: result.insertId
      });
    } catch (error) {
      console.error('Register error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    const [users] = await pool.query(
      'SELECT * FROM users WHERE username = ? AND active = 1',
      [username]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Update last login
    await pool.query('UPDATE users SET last_login = NOW() WHERE user_id = ?', [user.user_id]);

    // Generate token
    const token = jwt.sign(
      { user_id: user.user_id, username: user.username, role: user.role },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    res.json({
      token,
      user: {
        user_id: user.user_id,
        username: user.username,
        email: user.email,
        role: user.role,
        full_name: user.full_name
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get current user
app.get('/api/auth/me', authenticateToken, async (req, res) => {
  try {
    const [users] = await pool.query(
      'SELECT user_id, username, email, role, full_name, created_at FROM users WHERE user_id = ?',
      [req.user.user_id]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(users[0]);
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ==================== FERRET ROUTES ====================

// Get all ferrets with filtering
app.get('/api/ferrets', authenticateToken, async (req, res) => {
  try {
    const { search, location, sex, in_estrus, dead } = req.query;
    
    let query = `
      SELECT f.*, 
        a.cage_address, a.room_lighting,
        m.castrated_or_spayed, m.dead as is_dead, m.date_of_death,
        e.in_estrus, e.estrus_status, e.vulva_description,
        s.supplier_name
      FROM ferret_qr005 f
      LEFT JOIN address a ON f.address_id = a.address_id
      LEFT JOIN medical_info m ON f.medical_info_id = m.medical_info_id
      LEFT JOIN estrus_check_log e ON f.estrus_check_log_id = e.estrus_check_log_id
      LEFT JOIN supplier s ON f.supplier_id = s.supplier_id
      WHERE 1=1
    `;
    
    const params = [];

    if (search) {
      query += ' AND (f.ferret_name LIKE ? OR f.animal_id LIKE ? OR a.cage_address LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    if (location) {
      query += ' AND a.cage_address = ?';
      params.push(location);
    }

    if (sex) {
      query += ' AND f.description LIKE ?';
      params.push(`%${sex}%`);
    }

    if (in_estrus) {
      query += ' AND e.in_estrus = ?';
      params.push(in_estrus);
    }

    if (dead !== undefined) {
      query += ' AND (m.dead = ? OR f.dead = ?)';
      params.push(dead, dead);
    }

    query += ' ORDER BY f.ferret_name';

    const [ferrets] = await pool.query(query, params);
    res.json(ferrets);
  } catch (error) {
    console.error('Get ferrets error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get single ferret with full details
app.get('/api/ferrets/:id', authenticateToken, async (req, res) => {
  try {
    const [ferrets] = await pool.query(`
      SELECT f.*, 
        a.cage_address, a.room_lighting, a.maintenance,
        m.*, 
        e.*,
        s.supplier_name, s.contact_info,
        mother.ferret_name as mother_name,
        father.ferret_name as father_name
      FROM ferret_qr005 f
      LEFT JOIN address a ON f.address_id = a.address_id
      LEFT JOIN medical_info m ON f.medical_info_id = m.medical_info_id
      LEFT JOIN estrus_check_log e ON f.estrus_check_log_id = e.estrus_check_log_id
      LEFT JOIN supplier s ON f.supplier_id = s.supplier_id
      LEFT JOIN ferret_qr005 mother ON f.mother_id = mother.Ferret_QR005_id
      LEFT JOIN ferret_qr005 father ON f.father_id = father.Ferret_QR005_id
      WHERE f.Ferret_QR005_id = ?
    `, [req.params.id]);

    if (ferrets.length === 0) {
      return res.status(404).json({ error: 'Ferret not found' });
    }

    // Get health events
    const [healthEvents] = await pool.query(
      'SELECT * FROM health_event WHERE ferret_id = ? ORDER BY event_date DESC',
      [req.params.id]
    );

    // Get location history
    const [locationHistory] = await pool.query(`
      SELECT lh.*, a.cage_address
      FROM ferret_location_history lh
      LEFT JOIN address a ON lh.address_id = a.address_id
      WHERE lh.ferret_id = ?
      ORDER BY lh.move_in DESC
    `, [req.params.id]);

    // Get vaccination events
    const [vaccinations] = await pool.query(
      'SELECT * FROM vaccination_event WHERE ferret_id = ? ORDER BY vaccination_date DESC',
      [req.params.id]
    );

    // Get breeding history
    const [breedingHistory] = await pool.query(
      'SELECT * FROM estrus_&_mating_summary WHERE Ferret_QR005_id = ? ORDER BY created DESC',
      [req.params.id]
    );

    res.json({
      ...ferrets[0],
      health_events: healthEvents,
      location_history: locationHistory,
      vaccinations: vaccinations,
      breeding_history: breedingHistory
    });
  } catch (error) {
    console.error('Get ferret error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update ferret genealogy
app.put('/api/ferrets/:id/genealogy',
  authenticateToken,
  authorize('admin', 'research'),
  async (req, res) => {
    try {
      const { mother_id, father_id } = req.body;

      await pool.query(
        'UPDATE ferret_qr005 SET mother_id = ?, father_id = ? WHERE Ferret_QR005_id = ?',
        [mother_id, father_id, req.params.id]
      );

      res.json({ message: 'Genealogy updated successfully' });
    } catch (error) {
      console.error('Update genealogy error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// Update estrus status
app.put('/api/ferrets/:id/estrus',
  authenticateToken,
  authorize('admin', 'research', 'maternity'),
  async (req, res) => {
    try {
      const { in_estrus, estrus_status, vulva_description, comments } = req.body;

      // Get estrus_check_log_id for this ferret
      const [ferret] = await pool.query(
        'SELECT estrus_check_log_id FROM ferret_qr005 WHERE Ferret_QR005_id = ?',
        [req.params.id]
      );

      if (ferret.length === 0) {
        return res.status(404).json({ error: 'Ferret not found' });
      }

      // Update estrus check log
      await pool.query(`
        UPDATE estrus_check_log 
        SET in_estrus = ?, estrus_status = ?, vulva_description = ?, 
            comments = ?, reported_by = ?, formed_observation = NOW()
        WHERE estrus_check_log_id = ?
      `, [in_estrus, estrus_status, vulva_description, comments, req.user.username, ferret[0].estrus_check_log_id]);

      res.json({ message: 'Estrus status updated successfully' });
    } catch (error) {
      console.error('Update estrus error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// Upload ferret photo
app.post('/api/ferrets/:id/photo',
  authenticateToken,
  upload.single('photo'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
      }

      const photoUrl = `/uploads/ferrets/${req.file.filename}`;

      // Store photo reference (you may want to add a photos table)
      await pool.query(
        'UPDATE ferret_qr005 SET photo_url = ? WHERE Ferret_QR005_id = ?',
        [photoUrl, req.params.id]
      );

      res.json({ photo_url: photoUrl });
    } catch (error) {
      console.error('Upload photo error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// ==================== HEALTH EVENT ROUTES ====================

app.post('/api/health-events',
  authenticateToken,
  [
    body('ferret_id').isInt(),
    body('event_type').isIn(['weight', 'bath', 'nail_trim']),
    body('event_date').isDate()
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { ferret_id, event_type, weight, event_date, notes } = req.body;

      const [result] = await pool.query(
        'INSERT INTO health_event (ferret_id, event_type, weight, event_date, notes, recorded_by) VALUES (?, ?, ?, ?, ?, ?)',
        [ferret_id, event_type, weight, event_date, notes, req.user.username]
      );

      res.status(201).json({
        message: 'Health event recorded',
        health_event_id: result.insertId
      });
    } catch (error) {
      console.error('Create health event error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// ==================== LOCATION ROUTES ====================

// Get all locations with ferret counts
app.get('/api/locations', authenticateToken, async (req, res) => {
  try {
    const [locations] = await pool.query(`
      SELECT a.*, COUNT(f.Ferret_QR005_id) as ferret_count
      FROM address a
      LEFT JOIN ferret_qr005 f ON a.address_id = f.address_id AND (f.dead = '0' OR f.dead IS NULL)
      GROUP BY a.address_id
      ORDER BY a.cage_address
    `);

    res.json(locations);
  } catch (error) {
    console.error('Get locations error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Move ferret to new location
app.post('/api/locations/move',
  authenticateToken,
  async (req, res) => {
    try {
      const { ferret_id, new_address_id, reason } = req.body;

      // Get current location
      const [ferret] = await pool.query(
        'SELECT address_id FROM ferret_qr005 WHERE Ferret_QR005_id = ?',
        [ferret_id]
      );

      if (ferret.length === 0) {
        return res.status(404).json({ error: 'Ferret not found' });
      }

      // Close current location record
      await pool.query(
        'UPDATE ferret_location_history SET move_out = NOW() WHERE ferret_id = ? AND move_out IS NULL',
        [ferret_id]
      );

      // Create new location record
      await pool.query(
        'INSERT INTO ferret_location_history (ferret_id, address_id, move_in) VALUES (?, ?, NOW())',
        [ferret_id, new_address_id]
      );

      // Update ferret's current address
      await pool.query(
        'UPDATE ferret_qr005 SET address_id = ? WHERE Ferret_QR005_id = ?',
        [new_address_id, ferret_id]
      );

      res.json({ message: 'Ferret moved successfully' });
    } catch (error) {
      console.error('Move ferret error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// Update location details
app.put('/api/locations/:id',
  authenticateToken,
  authorize('admin', 'caretaker'),
  async (req, res) => {
    try {
      const { cage_address, room_lighting, maintenance } = req.body;

      await pool.query(
        'UPDATE address SET cage_address = ?, room_lighting = ?, maintenance = ? WHERE address_id = ?',
        [cage_address, room_lighting, maintenance, req.params.id]
      );

      res.json({ message: 'Location updated successfully' });
    } catch (error) {
      console.error('Update location error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// ==================== VACCINATION ROUTES ====================

app.post('/api/vaccinations',
  authenticateToken,
  authorize('admin', 'research'),
  async (req, res) => {
    try {
      const { ferret_id, vaccine_type, vaccination_date, expiration_date, notes } = req.body;

      const [result] = await pool.query(
        'INSERT INTO vaccination_event (ferret_id, vaccine_type, vaccination_date, expiration_date, notes, recorded_by) VALUES (?, ?, ?, ?, ?, ?)',
        [ferret_id, vaccine_type, vaccination_date, expiration_date, notes, req.user.username]
      );

      // Update next vaccine due date on ferret record
      if (vaccine_type === 'rabies' && expiration_date) {
        await pool.query(
          'UPDATE ferret_qr005 SET next_rabies_vaccine_due = ? WHERE Ferret_QR005_id = ?',
          [expiration_date, ferret_id]
        );
      }

      res.status(201).json({
        message: 'Vaccination recorded',
        vaccination_event_id: result.insertId
      });
    } catch (error) {
      console.error('Create vaccination error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// Get upcoming vaccines (for notifications)
app.get('/api/vaccinations/upcoming', authenticateToken, async (req, res) => {
  try {
    const daysAhead = req.query.days || 30;

    const [upcoming] = await pool.query(`
      SELECT f.Ferret_QR005_id, f.ferret_name, f.animal_id, f.next_rabies_vaccine_due,
        a.cage_address
      FROM ferret_qr005 f
      LEFT JOIN address a ON f.address_id = a.address_id
      WHERE f.next_rabies_vaccine_due <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
        AND (f.dead = '0' OR f.dead IS NULL)
      ORDER BY f.next_rabies_vaccine_due
    `, [daysAhead]);

    res.json(upcoming);
  } catch (error) {
    console.error('Get upcoming vaccines error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ==================== EXPORT ROUTES ====================

// Export ferrets to CSV
app.get('/api/export/csv', authenticateToken, async (req, res) => {
  try {
    const [ferrets] = await pool.query(`
      SELECT f.ferret_name, f.animal_id, f.birth_date, f.weight, 
        a.cage_address, s.supplier_name, f.description,
        m.castrated_or_spayed, e.in_estrus
      FROM ferret_qr005 f
      LEFT JOIN address a ON f.address_id = a.address_id
      LEFT JOIN supplier s ON f.supplier_id = s.supplier_id
      LEFT JOIN medical_info m ON f.medical_info_id = m.medical_info_id
      LEFT JOIN estrus_check_log e ON f.estrus_check_log_id = e.estrus_check_log_id
      WHERE f.dead = '0' OR f.dead IS NULL
    `);

    // Convert to CSV
    const headers = ['Name', 'ID', 'Birth Date', 'Weight', 'Location', 'Supplier', 'Description', 'Altered', 'In Estrus'];
    const csv = [
      headers.join(','),
      ...ferrets.map(f => [
        f.ferret_name,
        f.animal_id,
        f.birth_date,
        f.weight,
        f.cage_address,
        f.supplier_name,
        f.description,
        f.castrated_or_spayed,
        f.in_estrus
      ].map(val => `"${val || ''}"`).join(','))
    ].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=ferrets-export.csv');
    res.send(csv);
  } catch (error) {
    console.error('Export CSV error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ==================== PUSH NOTIFICATION ROUTES ====================

// Save subscription
app.post('/api/notifications/subscribe', authenticateToken, async (req, res) => {
  try {
    const { subscription } = req.body;

    await pool.query(
      'INSERT INTO push_subscriptions (user_id, subscription_data) VALUES (?, ?) ON DUPLICATE KEY UPDATE subscription_data = ?',
      [req.user.user_id, JSON.stringify(subscription), JSON.stringify(subscription)]
    );

    res.json({ message: 'Subscription saved' });
  } catch (error) {
    console.error('Save subscription error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Send vaccine reminder notifications (called by cron job)
app.post('/api/notifications/send-vaccine-reminders',
  authenticateToken,
  authorize('admin'),
  async (req, res) => {
    try {
      // Get upcoming vaccines
      const [vaccines] = await pool.query(`
        SELECT f.ferret_name, f.next_rabies_vaccine_due
        FROM ferret_qr005 f
        WHERE f.next_rabies_vaccine_due <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
          AND (f.dead = '0' OR f.dead IS NULL)
      `);

      if (vaccines.length === 0) {
        return res.json({ message: 'No upcoming vaccines' });
      }

      // Get subscriptions for admin and research users
      const [subscriptions] = await pool.query(`
        SELECT ps.subscription_data
        FROM push_subscriptions ps
        JOIN users u ON ps.user_id = u.user_id
        WHERE u.role IN ('admin', 'research') AND u.active = 1
      `);

      const notificationPayload = JSON.stringify({
        title: 'Vaccine Reminders',
        body: `${vaccines.length} ferret(s) have vaccines due soon`,
        icon: '/icon-192.png'
      });

      // Send to all subscriptions
      const promises = subscriptions.map(sub => {
        return webPush.sendNotification(
          JSON.parse(sub.subscription_data),
          notificationPayload
        ).catch(err => console.error('Push error:', err));
      });

      await Promise.all(promises);

      res.json({ message: `Notifications sent to ${subscriptions.length} users` });
    } catch (error) {
      console.error('Send notifications error:', error);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// ==================== STATS/DASHBOARD ====================

app.get('/api/stats', authenticateToken, async (req, res) => {
  try {
    const [stats] = await pool.query(`
      SELECT 
        COUNT(*) as total_ferrets,
        SUM(CASE WHEN f.description LIKE '%Female%' THEN 1 ELSE 0 END) as female_count,
        SUM(CASE WHEN e.in_estrus = '1' THEN 1 ELSE 0 END) as in_estrus_count,
        SUM(CASE WHEN f.next_rabies_vaccine_due <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as vaccines_due
      FROM ferret_qr005 f
      LEFT JOIN estrus_check_log e ON f.estrus_check_log_id = e.estrus_check_log_id
      WHERE (f.dead = '0' OR f.dead IS NULL)
    `);

    res.json(stats[0]);
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, () => {
  console.log(`SanusBio API server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
