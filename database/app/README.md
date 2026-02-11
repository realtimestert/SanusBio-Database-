# SanusBio Ferret Colony Manager - Full Stack Setup Guide

## Overview

This is a complete ferret colony management system with:
- **Backend**: Node.js + Express + MySQL
- **Frontend**: React (single-page PWA)
- **Features**: Auth, photo uploads, health tracking, breeding management, location management, exports, push notifications

## Prerequisites

- Node.js 18+ and npm
- MySQL 8.0+
- Modern web browser

## Database Setup

### 1. Install MySQL

```bash
# macOS
brew install mysql
brew services start mysql

# Ubuntu/Debian
sudo apt-get install mysql-server
sudo systemctl start mysql

# Windows
# Download from https://dev.mysql.com/downloads/mysql/
```

### 2. Create Database

```bash
mysql -u root -p
```

```sql
CREATE DATABASE sanusbio;
USE sanusbio;
```

### 3. Run Schema

```bash
# First, run your original schema
mysql -u root -p sanusbio < /path/to/sanusbio_database_schema.sql

# Then run additional tables
mysql -u root -p sanusbio < backend/schema_additions.sql
```

### 4. Create Admin User

```bash
# Generate password hash
node -e "console.log(require('bcryptjs').hashSync('admin123', 10))"
# Copy the output hash
```

```sql
USE sanusbio;

INSERT INTO users (username, password, email, role, full_name) 
VALUES ('admin', 'PASTE_HASH_HERE', 'admin@sanusbio.com', 'admin', 'System Administrator');
```

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
nano .env
```

Update `.env`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=sanusbio
JWT_SECRET=change-this-to-random-string
PORT=3000
NODE_ENV=development
```

### 3. Generate VAPID Keys (for push notifications)

```bash
npx web-push generate-vapid-keys
```

Copy the keys to `.env`:
```env
VAPID_PUBLIC_KEY=your_public_key
VAPID_PRIVATE_KEY=your_private_key
```

### 4. Start Backend

```bash
# Development mode (auto-restart on changes)
npm run dev

# Production mode
npm start
```

Backend will run on `http://localhost:3000`

## Frontend Setup

### Option 1: Simple HTTP Server

```bash
cd frontend

# Using Python
python3 -m http.server 5173

# Using Node.js http-server
npx http-server -p 5173
```

### Option 2: Production Build

For production, you should use a proper web server like nginx or Apache to serve the frontend files.

## First Time Setup

### 1. Access the Application

Open browser to `http://localhost:5173`

### 2. Login

```
Username: admin
Password: admin123
```

**IMPORTANT**: Change this password immediately!

### 3. Create Additional Users

As admin:
1. Navigate to Settings
2. Click "Manage Users"
3. Add users with appropriate roles:
   - **admin**: Full access
   - **research**: Health, breeding, vaccines
   - **maternity**: Breeding, health, litters
   - **caretaker**: Basic care, cleaning

## Features Guide

### Photo Uploads

1. View ferret detail page
2. Click upload icon in header
3. Select photo (max 5MB)
4. Photo will be saved to `backend/uploads/ferrets/`

### Genealogy Editing

1. View ferret detail page → Info tab
2. Click "Edit" on Genealogy section
3. Select mother and father from dropdowns
4. Save

### Estrus Status Management

1. View ferret detail page → Breeding tab
2. Click "Update" on Estrus Status
3. Set:
   - In Estrus (yes/no)
   - Estrus Status
   - Vulva Description
   - Comments
4. Save

### Location Management

**View Locations:**
- Navigate to Locations tab
- See all cages with ferret counts
- Click cage to see occupants

**Move Ferret:**
1. View ferret detail → Location tab
2. Click "Move Ferret"
3. Select new location
4. Add reason (optional)
5. Save

**View Location History:**
- On ferret detail → Location tab
- See complete timeline of moves

### Health Event Recording

1. Click + button (FAB)
2. Select ferret (if not already selected)
3. Choose event type:
   - Weight Check
   - Bath
   - Nail Trim
   - Health Check
   - Vaccination
4. Enter details
5. Save

### Vaccination Management

1. Ferret detail → Health tab
2. Click "Add Vaccine"
3. Enter:
   - Vaccine type (rabies, distemper, other)
   - Date
   - Expiration date
   - Notes
4. Save

### Data Export

**CSV Export:**
- Click download icon in header
- CSV file downloads automatically

**PDF Export:**
(To be implemented - currently requires server-side generation)

### Push Notifications

**For Admin/Research users:**

1. Navigate to Settings
2. Enable notifications
3. Browser will prompt for permission
4. You'll receive alerts for:
   - Vaccines due within 7 days
   - Important colony events

## API Endpoints

### Authentication
```
POST   /api/auth/login          - Login
POST   /api/auth/register       - Register user (admin only)
GET    /api/auth/me             - Get current user
```

### Ferrets
```
GET    /api/ferrets             - List all ferrets
GET    /api/ferrets/:id         - Get ferret details
PUT    /api/ferrets/:id/genealogy  - Update genealogy
PUT    /api/ferrets/:id/estrus     - Update estrus status
POST   /api/ferrets/:id/photo      - Upload photo
```

### Health
```
POST   /api/health-events       - Create health event
GET    /api/health-events       - List events
```

### Locations
```
GET    /api/locations           - List all locations
POST   /api/locations/move      - Move ferret
PUT    /api/locations/:id       - Update location
```

### Vaccinations
```
POST   /api/vaccinations        - Record vaccination
GET    /api/vaccinations/upcoming  - Get upcoming vaccines
```

### Export
```
GET    /api/export/csv          - Export ferrets to CSV
```

### Stats
```
GET    /api/stats               - Get dashboard statistics
```

## Role-Based Permissions

### Admin
- Full access to all features
- User management
- System settings
- All CRUD operations

### Research
- View all ferrets
- Edit health records
- Edit genealogy
- Record vaccinations
- Manage breeding
- Export data
- Receive notifications

### Maternity
- View ferrets
- Update estrus status
- Record breeding
- Manage litters
- Basic health records

### Caretaker
- View ferrets
- Record cleaning/maintenance
- Basic health events (weight, baths, nails)
- No data export
- No genealogy editing

## Security Considerations

### Production Deployment

1. **Change Default Credentials**
   ```sql
   UPDATE users SET password = 'NEW_HASH' WHERE username = 'admin';
   ```

2. **Use Strong JWT Secret**
   ```bash
   # Generate random secret
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```

3. **Enable HTTPS**
   - Use Let's Encrypt for SSL certificates
   - Configure nginx/Apache with SSL

4. **Secure Database**
   ```sql
   CREATE USER 'sanusbio'@'localhost' IDENTIFIED BY 'strong_password';
   GRANT ALL PRIVILEGES ON sanusbio.* TO 'sanusbio'@'localhost';
   FLUSH PRIVILEGES;
   ```

5. **Environment Variables**
   - Never commit `.env` to version control
   - Use environment-specific configs

6. **File Uploads**
   - Current max: 5MB
   - Only images allowed
   - Files stored in `uploads/ferrets/`

## Troubleshooting

### Backend won't start

**Error: "connect ECONNREFUSED"**
- MySQL is not running
- Check credentials in `.env`

**Error: "Table doesn't exist"**
- Run schema files
- Check database name

### Frontend can't connect

**CORS errors:**
- Update `CORS_ORIGIN` in backend `.env`
- Restart backend server

**401 Unauthorized:**
- Token expired - logout and login again
- Check backend is running

### Photos won't upload

**Error: "No file uploaded"**
- Check file size (<5MB)
- Only JPG, PNG, GIF allowed
- Check `uploads/ferrets/` directory exists

## Backup & Maintenance

### Database Backup

```bash
# Backup
mysqldump -u root -p sanusbio > backup_$(date +%Y%m%d).sql

# Restore
mysql -u root -p sanusbio < backup_20260210.sql
```

### Scheduled Tasks

Set up cron jobs for:

**Daily vaccine notifications (8 AM):**
```cron
0 8 * * * curl -X POST http://localhost:3000/api/notifications/send-vaccine-reminders \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

**Weekly database backup:**
```cron
0 2 * * 0 mysqldump -u root -p sanusbio > /backups/sanusbio_$(date +%Y%m%d).sql
```

## Performance Optimization

### Database Indexing

Already included in schema, but verify:
```sql
SHOW INDEXES FROM ferret_qr005;
SHOW INDEXES FROM health_event;
```

### Backend Caching

Consider adding Redis for:
- Session storage
- Frequently accessed data
- API response caching

### Frontend Optimization

- Images are served from backend
- Consider CDN for production
- Enable gzip compression on web server

## Future Enhancements

Planned features:
- [ ] Litter management improvements
- [ ] Advanced reporting
- [ ] Batch operations
- [ ] QR code scanning
- [ ] Mobile app (React Native)
- [ ] Data visualization charts
- [ ] Email notifications
- [ ] Audit logging improvements
- [ ] Advanced search filters
- [ ] Pregnancy tracking timeline

## Support & Contact

For issues, feature requests, or questions:
- Check this documentation first
- Review error logs: `backend/logs/`
- Check browser console for frontend errors
- Review MySQL error log

## License

Internal use - SanusBio Laboratory

---

**Version**: 1.0.0
**Last Updated**: February 2026
**Maintained by**: SanusBio Development Team
