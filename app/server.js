require('dotenv').config();
const express  = require('express');
const mysql    = require('mysql2/promise');
const jwt      = require('jsonwebtoken');
const bcrypt   = require('bcryptjs');
const cors     = require('cors');
const path     = require('path');

const app  = express();
const PORT = process.env.PORT || 4000;
const SECRET = process.env.JWT_SECRET || 'change-this-secret';

app.use(express.json());
app.use(cors());

// ─── Database ─────────────────────────────────────────────────────────────────
const pool = mysql.createPool({
  host:             process.env.DB_HOST || 'localhost',
  user:             process.env.DB_USER || 'root',
  password:         process.env.DB_PASS || '',
  database:         process.env.DB_NAME || 'sanusbio',
  waitForConnections: true,
  connectionLimit:  10,
  charset:          'utf8mb4'
});

// ─── Role Permission Map ──────────────────────────────────────────────────────
//  admin     → full access (read, write, update, delete, manage_users)
//  research  → read-only
//  maternity → read + write/update litter, estrus, health data; no delete
//  caretaker → read (own view) + write health events + complete own assignments
const PERMS = {
  admin:     new Set(['read', 'write', 'update', 'delete', 'manage_users']),
  research:  new Set(['read']),
  maternity: new Set(['read', 'write', 'update']),
  caretaker: new Set(['read', 'write'])
};

function can(role, action) {
  return PERMS[role]?.has(action) ?? false;
}

// ─── Middleware ───────────────────────────────────────────────────────────────
function authenticate(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ error: 'No authorization header' });
  const token = header.split(' ')[1];
  try {
    req.user = jwt.verify(token, SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}

function require_perm(action) {
  return (req, res, next) => {
    if (!can(req.user.role, action)) {
      return res.status(403).json({ error: `Role '${req.user.role}' cannot perform this action` });
    }
    next();
  };
}

function admin_only(req, res, next) {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'Admin access required' });
  next();
}

async function log_activity(user_id, action, table_name = null, record_id = null, details = null) {
  try {
    await pool.query(
      'INSERT INTO activity_log (user_id, action, table_name, record_id, details) VALUES (?,?,?,?,?)',
      [user_id, action, table_name, record_id, details]
    );
  } catch { /* non-fatal */ }
}

// ─── Serve Frontend ───────────────────────────────────────────────────────────
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'index.html')));

// ─── Auth ─────────────────────────────────────────────────────────────────────
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) return res.status(400).json({ error: 'Username and password required' });
  try {
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE username = ? AND active = 1', [username]
    );
    if (!rows.length) return res.status(401).json({ error: 'Invalid username or password' });
    const user = rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ error: 'Invalid username or password' });
    await pool.query('UPDATE users SET last_login = NOW() WHERE user_id = ?', [user.user_id]);
    const token = jwt.sign(
      { user_id: user.user_id, username: user.username, role: user.role, full_name: user.full_name },
      SECRET,
      { expiresIn: '8h' }
    );
    await log_activity(user.user_id, 'LOGIN', 'users', user.user_id, `${user.username} logged in`);
    res.json({
      token,
      user: { user_id: user.user_id, username: user.username, role: user.role, full_name: user.full_name }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/me', authenticate, (req, res) => res.json(req.user));

// ─── Dashboard Stats ──────────────────────────────────────────────────────────
app.get('/api/dashboard', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [[{ total }]]       = await pool.query("SELECT COUNT(*) as total FROM ferret_qr005 WHERE dead='0' OR dead IS NULL");
    const [[{ deceased }]]    = await pool.query("SELECT COUNT(*) as deceased FROM ferret_qr005 WHERE dead='1'");
    const [[{ overdue }]]     = await pool.query("SELECT COUNT(*) as overdue FROM assignments WHERE completed=0 AND due_date < CURDATE()");
    const [[{ vacc_due }]]    = await pool.query("SELECT COUNT(*) as vacc_due FROM ferret_qr005 WHERE next_rabies_vaccine_due <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) AND (dead='0' OR dead IS NULL)");
    const [recent_activity]   = await pool.query(`
      SELECT al.action, al.details, al.created_at, u.username
      FROM activity_log al JOIN users u ON al.user_id = u.user_id
      ORDER BY al.created_at DESC LIMIT 10
    `);
    res.json({ total, deceased, overdue, vacc_due, recent_activity });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Ferrets ──────────────────────────────────────────────────────────────────
app.get('/api/ferrets', authenticate, require_perm('read'), async (req, res) => {
  try {
    const q = req.query.search ? `%${req.query.search}%` : '%';
    const [rows] = await pool.query(`
      SELECT f.Ferret_QR005_id AS id, f.ferret_name AS name, f.animal_id,
             f.birth_date, f.weight, f.dead, f.description, f.litter_id,
             f.photo_url, f.mother_name, f.father_name, f.acquisition_by,
             f.next_rabies_vaccine_due,
             a.cage_address, a.room_id,
             s.supplier_name
      FROM ferret_qr005 f
      LEFT JOIN address a    ON f.address_id  = a.address_id
      LEFT JOIN supplier s   ON f.supplier_id = s.supplier_id
      WHERE f.ferret_name LIKE ? OR f.animal_id LIKE ?
      ORDER BY f.ferret_name
    `, [q, q]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/ferrets/:id', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT f.*,
             a.cage_address, a.room_id, a.room_lighting, a.maintenance,
             s.supplier_name, s.contact_info, s.supplier_phone_number,
             mi.castrated_or_spayed, mi.castration_or_spay_date,
             mi.dead AS med_dead, mi.date_of_death, mi.cause_of_death,
             mi.treatments, mi.last_exam_date, mi.orders, mi.performed_by,
             mi.weight_loss_or_gain, mi.exam_log,
             ecl.estrus_status, ecl.in_estrus, ecl.vulva_description,
             ecl.formed_observation, ecl.comments AS estrus_comments
      FROM ferret_qr005 f
      LEFT JOIN address         a   ON f.address_id          = a.address_id
      LEFT JOIN supplier        s   ON f.supplier_id         = s.supplier_id
      LEFT JOIN medical_info    mi  ON f.medical_info_id     = mi.medical_info_id
      LEFT JOIN estrus_check_log ecl ON f.estrus_check_log_id = ecl.estrus_check_log_id
      WHERE f.Ferret_QR005_id = ?
    `, [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Ferret not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create ferret — admin and maternity only; auto-creates required stub sub-records
app.post('/api/ferrets', authenticate, async (req, res) => {
  if (!['admin', 'maternity'].includes(req.user.role)) {
    return res.status(403).json({ error: 'Only admin and maternity roles can add ferrets' });
  }
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    // Stub records for required FKs (tables lack AUTO_INCREMENT in original schema — fixed by migrations.sql)
    const [mi]  = await conn.query('INSERT INTO medical_info () VALUES ()');
    const [ec]  = await conn.query('INSERT INTO estrus_check_log () VALUES ()');
    const [fm]  = await conn.query('INSERT INTO females_to_mate () VALUES ()');
    const [hl]  = await conn.query('INSERT INTO health_log () VALUES ()');

    const {
      ferret_name, animal_id, birth_date, weight = 0, description,
      address_id, supplier_id, mother_name, father_name,
      next_rabies_vaccine_due, acquisition_by, photo_url
    } = req.body;

    const [r] = await conn.query(`
      INSERT INTO ferret_qr005
        (ferret_name, animal_id, birth_date, weight, description, address_id,
         medical_info_id, estrus_check_log_id, females_to_mate_id, health_log_id,
         supplier_id, mother_name, father_name, next_rabies_vaccine_due,
         acquisition_by, photo_url, created_by, dead)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'','0')
    `, [ferret_name, animal_id || null, birth_date, weight, description || null,
        address_id, mi.insertId, ec.insertId, fm.insertId, hl.insertId,
        supplier_id, mother_name || null, father_name || null,
        next_rabies_vaccine_due || null, acquisition_by || null, photo_url || null]);

    await conn.commit();
    await log_activity(req.user.user_id, 'CREATE', 'ferret_qr005', r.insertId, `Created ferret: ${ferret_name}`);
    res.json({ id: r.insertId, message: 'Ferret created successfully' });
  } catch (err) {
    await conn.rollback();
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

// Update ferret — admin and maternity only
app.put('/api/ferrets/:id', authenticate, require_perm('update'), async (req, res) => {
  const allowed = ['ferret_name', 'weight', 'description', 'dead', 'next_rabies_vaccine_due', 'photo_url', 'acquisition_by'];
  const sets = [], vals = [];
  for (const key of allowed) {
    if (req.body[key] !== undefined) { sets.push(`${key} = ?`); vals.push(req.body[key]); }
  }
  if (!sets.length) return res.status(400).json({ error: 'No valid fields provided' });
  vals.push(req.params.id);
  try {
    await pool.query(`UPDATE ferret_qr005 SET ${sets.join(', ')} WHERE Ferret_QR005_id = ?`, vals);
    await log_activity(req.user.user_id, 'UPDATE', 'ferret_qr005', req.params.id, `Updated ferret #${req.params.id}`);
    res.json({ message: 'Ferret updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete ferret — admin only
app.delete('/api/ferrets/:id', authenticate, admin_only, async (req, res) => {
  try {
    await pool.query('DELETE FROM ferret_qr005 WHERE Ferret_QR005_id = ?', [req.params.id]);
    await log_activity(req.user.user_id, 'DELETE', 'ferret_qr005', req.params.id, `Deleted ferret #${req.params.id}`);
    res.json({ message: 'Ferret deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Health Events ────────────────────────────────────────────────────────────
app.get('/api/ferrets/:id/health', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM health_event WHERE ferret_id = ? ORDER BY event_date DESC', [req.params.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// All roles except research can record health events
app.post('/api/health-events', authenticate, require_perm('write'), async (req, res) => {
  if (req.user.role === 'research') return res.status(403).json({ error: 'Research role is read-only' });
  const { ferret_id, event_type, weight, event_date, notes } = req.body;
  try {
    const [r] = await pool.query(
      'INSERT INTO health_event (ferret_id, event_type, weight, event_date, notes, recorded_by) VALUES (?,?,?,?,?,?)',
      [ferret_id, event_type, weight || null, event_date, notes || null, req.user.username]
    );
    await log_activity(req.user.user_id, 'CREATE', 'health_event', r.insertId, `${event_type} for ferret #${ferret_id}`);
    res.json({ id: r.insertId, message: 'Health event recorded' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Vaccinations ─────────────────────────────────────────────────────────────
app.get('/api/ferrets/:id/vaccinations', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM vaccination_event WHERE ferret_id = ? ORDER BY vaccination_date DESC', [req.params.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Admin and maternity can record vaccinations
app.post('/api/vaccinations', authenticate, async (req, res) => {
  if (!['admin', 'maternity'].includes(req.user.role)) {
    return res.status(403).json({ error: 'Only admin and maternity can record vaccinations' });
  }
  const { ferret_id, vaccine_type, vaccination_date, expiration_date, notes } = req.body;
  try {
    const [r] = await pool.query(
      'INSERT INTO vaccination_event (ferret_id, vaccine_type, vaccination_date, expiration_date, notes, recorded_by) VALUES (?,?,?,?,?,?)',
      [ferret_id, vaccine_type, vaccination_date, expiration_date || null, notes || null, req.user.username]
    );
    res.json({ id: r.insertId, message: 'Vaccination recorded' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Litter Logs ──────────────────────────────────────────────────────────────
app.get('/api/ferrets/:id/litters', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM litter_log WHERE Ferret_QR005_id = ? ORDER BY litter_date DESC', [req.params.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/litters', authenticate, async (req, res) => {
  if (!['admin', 'maternity'].includes(req.user.role)) {
    return res.status(403).json({ error: 'Only admin and maternity can add litter records' });
  }
  const { Ferret_QR005_id, litter_id, litter_date, kit_count, stillborn, father, mother, anomalies_and_notes } = req.body;
  try {
    const [r] = await pool.query(
      `INSERT INTO litter_log (Ferret_QR005_id, litter_id, litter_date, kit_count, stillborn,
        father, mother, anomalies_and_notes, created, created_by)
       VALUES (?,?,?,?,?,?,?,?,CURDATE(),?)`,
      [Ferret_QR005_id, litter_id || null, litter_date, kit_count || null,
       stillborn || null, father || null, mother || null,
       anomalies_and_notes || null, req.user.username]
    );
    await log_activity(req.user.user_id, 'CREATE', 'litter_log', r.insertId, `Litter for ferret #${Ferret_QR005_id}`);
    res.json({ id: r.insertId, message: 'Litter recorded' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Assignments ──────────────────────────────────────────────────────────────
app.get('/api/assignments', authenticate, require_perm('read'), async (req, res) => {
  try {
    let q = `
      SELECT a.*,
             u.username  AS assigned_username, u.full_name AS assigned_full_name,
             c.username  AS creator_username,
             f.ferret_name
      FROM assignments a
      JOIN  users u ON a.assigned_to = u.user_id
      JOIN  users c ON a.created_by  = c.user_id
      LEFT JOIN ferret_qr005 f ON a.ferret_id = f.Ferret_QR005_id
    `;
    const params = [];
    // Non-admin/research see only their own assignments
    if (!['admin', 'research'].includes(req.user.role)) {
      q += ' WHERE a.assigned_to = ?';
      params.push(req.user.user_id);
    }
    q += ' ORDER BY a.completed ASC, a.due_date ASC';
    const [rows] = await pool.query(q, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/assignments', authenticate, admin_only, async (req, res) => {
  const { assigned_to, assignment_type, address_id, ferret_id, description, due_date } = req.body;
  try {
    const [r] = await pool.query(
      `INSERT INTO assignments (assigned_to, assignment_type, address_id, ferret_id, description, due_date, created_by)
       VALUES (?,?,?,?,?,?,?)`,
      [assigned_to, assignment_type, address_id || null, ferret_id || null, description || null, due_date, req.user.user_id]
    );
    await log_activity(req.user.user_id, 'CREATE', 'assignments', r.insertId, `Assigned to user #${assigned_to}`);
    res.json({ id: r.insertId, message: 'Assignment created' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Any user can complete their own assignment; admin can complete any
app.put('/api/assignments/:id/complete', authenticate, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM assignments WHERE assignment_id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Assignment not found' });
    if (req.user.role !== 'admin' && rows[0].assigned_to !== req.user.user_id) {
      return res.status(403).json({ error: 'You can only complete your own assignments' });
    }
    await pool.query(
      'UPDATE assignments SET completed = 1, completed_at = NOW() WHERE assignment_id = ?', [req.params.id]
    );
    await log_activity(req.user.user_id, 'COMPLETE', 'assignments', req.params.id, 'Assignment marked complete');
    res.json({ message: 'Assignment completed' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Reference Data ───────────────────────────────────────────────────────────
app.get('/api/suppliers', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM supplier ORDER BY supplier_name');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/suppliers', authenticate, admin_only, async (req, res) => {
  const { supplier_name, contact_info, supplier_address, supplier_phone_number } = req.body;
  try {
    const [r] = await pool.query(
      'INSERT INTO supplier (supplier_name, contact_info, supplier_address, supplier_phone_number) VALUES (?,?,?,?)',
      [supplier_name, contact_info || null, supplier_address || null, supplier_phone_number || null]
    );
    res.json({ id: r.insertId, message: 'Supplier added' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/addresses', authenticate, require_perm('read'), async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM address ORDER BY room_id, cage_address');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/addresses', authenticate, admin_only, async (req, res) => {
  const { room_id, cage_address, room_lighting, maintenance } = req.body;
  try {
    const [r] = await pool.query(
      'INSERT INTO address (room_id, cage_address, room_lighting, maintenance) VALUES (?,?,?,?)',
      [room_id, cage_address || null, room_lighting || null, maintenance || null]
    );
    res.json({ id: r.insertId, message: 'Address added' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── User Management (Admin Only) ─────────────────────────────────────────────
app.get('/api/users', authenticate, admin_only, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT user_id, username, email, role, full_name, active, created_at, last_login FROM users ORDER BY username'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/users', authenticate, admin_only, async (req, res) => {
  const { username, password, email, role, full_name } = req.body;
  if (!username || !password || !email || !role) {
    return res.status(400).json({ error: 'username, password, email, and role are required' });
  }
  try {
    const hashed = await bcrypt.hash(password, 12);
    const [r] = await pool.query(
      'INSERT INTO users (username, password, email, role, full_name) VALUES (?,?,?,?,?)',
      [username, hashed, email, role, full_name || null]
    );
    await log_activity(req.user.user_id, 'CREATE_USER', 'users', r.insertId, `Created user: ${username} (${role})`);
    res.json({ id: r.insertId, message: 'User created' });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return res.status(400).json({ error: 'Username or email already exists' });
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/users/:id', authenticate, admin_only, async (req, res) => {
  const { email, role, full_name, active, password } = req.body;
  const sets = [], vals = [];
  if (email       !== undefined) { sets.push('email = ?');     vals.push(email); }
  if (role        !== undefined) { sets.push('role = ?');      vals.push(role); }
  if (full_name   !== undefined) { sets.push('full_name = ?'); vals.push(full_name); }
  if (active      !== undefined) { sets.push('active = ?');    vals.push(active); }
  if (password)                  { sets.push('password = ?');  vals.push(await bcrypt.hash(password, 12)); }
  if (!sets.length) return res.status(400).json({ error: 'Nothing to update' });
  vals.push(req.params.id);
  try {
    await pool.query(`UPDATE users SET ${sets.join(', ')} WHERE user_id = ?`, vals);
    await log_activity(req.user.user_id, 'UPDATE_USER', 'users', req.params.id, 'User updated');
    res.json({ message: 'User updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Activity Log (Admin Only) ────────────────────────────────────────────────
app.get('/api/activity-log', authenticate, admin_only, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT al.*, u.username
      FROM activity_log al JOIN users u ON al.user_id = u.user_id
      ORDER BY al.created_at DESC LIMIT 500
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── Start ────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🐾 SanusBio running → http://localhost:${PORT}`);
  console.log(`   Roles: admin > research > maternity > caretaker\n`);
});