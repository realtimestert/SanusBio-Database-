# SanusBio — Setup Guide

## Files in this directory

```
sanusbio/
  server.js              ← Express backend (API + auth + RBAC)
  index.html             ← Single-page frontend
  package.json           ← Node dependencies
  .env.example           ← Environment variable template
  migrations.sql         ← Run after importing the schema
  sanusbio.service       ← Systemd service (runs on boot)
  SETUP.md               ← This file
```

---

## Step 1 — Install Node.js on Ubuntu 24.04

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v   # should show v20.x
```

---

## Step 2 — Copy the project to your server

From your Windows machine (PowerShell or terminal with SSH):

```powershell
scp -r C:\path\to\sanusbio stuart@<server-ip>:/home/stuart/
```

Or create the folder directly on the server:

```bash
mkdir ~/sanusbio
# then paste each file's content manually, or use scp
```

---

## Step 3 — Import the database schema

```bash
# Import the original schema
mysql -u root -p < /path/to/sanusbio_database_schema.sql

# Then run the migrations (adds AUTO_INCREMENT to PKs that were missing it)
mysql -u root -p < ~/sanusbio/migrations.sql
```

---

## Step 4 — Create a MySQL app user (recommended over root)

```sql
-- Run inside MySQL as root:
mysql -u root -p

CREATE USER 'sanusbio_app'@'localhost' IDENTIFIED BY 'StrongPasswordHere';
GRANT SELECT, INSERT, UPDATE, DELETE ON sanusbio.* TO 'sanusbio_app'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## Step 5 — Configure environment variables

```bash
cd ~/sanusbio
cp .env.example .env
nano .env
```

Fill in your values:

```
PORT=4000
DB_HOST=localhost
DB_USER=sanusbio_app
DB_PASS=StrongPasswordHere
DB_NAME=sanusbio
JWT_SECRET=<run: openssl rand -hex 32>
```

---

## Step 6 — Install Node dependencies

```bash
cd ~/sanusbio
npm install
```

---

## Step 7 — Create your first admin user

Run this once to seed the admin account (replace values as needed):

```bash
node -e "
const bcrypt = require('bcryptjs');
const mysql  = require('mysql2/promise');
require('dotenv').config();
(async () => {
  const db = await mysql.createConnection({
    host: process.env.DB_HOST, user: process.env.DB_USER,
    password: process.env.DB_PASS, database: process.env.DB_NAME
  });
  const hash = await bcrypt.hash('AdminPassword123!', 12);
  await db.query(
    'INSERT INTO users (username, password, email, role, full_name) VALUES (?,?,?,?,?)',
    ['admin', hash, 'admin@yourdomain.com', 'admin', 'System Admin']
  );
  console.log('Admin user created.');
  process.exit(0);
})();
"
```

---

## Step 8 — Test it manually first

```bash
cd ~/sanusbio
node server.js
# Should print: 🐾 SanusBio running → http://localhost:4000
```

Open in your browser (from Windows, SSH tunnel or local network):
```
http://<server-ip>:4000
```

Press Ctrl+C to stop once confirmed working.

---

## Step 9 — Install as a systemd service (runs on boot)

```bash
# Copy the service file
sudo cp ~/sanusbio/sanusbio.service /etc/systemd/system/

# Reload systemd, enable and start
sudo systemctl daemon-reload
sudo systemctl enable sanusbio
sudo systemctl start sanusbio

# Check status
sudo systemctl status sanusbio

# View live logs
sudo journalctl -u sanusbio -f
```

---

## Role Permissions Summary

| Action                        | Admin | Maternity | Research | Caretaker |
|-------------------------------|:-----:|:---------:|:--------:|:---------:|
| View all ferrets & data       |  ✅   |    ✅     |    ✅    |    ✅     |
| Record health events          |  ✅   |    ✅     |    ❌    |    ✅     |
| Add ferrets / litters / vacc  |  ✅   |    ✅     |    ❌    |    ❌     |
| Update ferret records         |  ✅   |    ✅     |    ❌    |    ❌     |
| Delete ferrets                |  ✅   |    ❌     |    ❌    |    ❌     |
| Create & view all assignments |  ✅   |    ❌     |    ✅    |    ❌     |
| Complete own assignments      |  ✅   |    ✅     |    ❌    |    ✅     |
| Manage users                  |  ✅   |    ❌     |    ❌    |    ❌     |
| View activity log             |  ✅   |    ❌     |    ❌    |    ❌     |

---

## Adding locations and suppliers (Admin only)

Before you can add ferrets, you need at least one **address** (location) and
one **supplier** in the database. You can add them two ways:

**Option A — SQL directly:**
```sql
INSERT INTO sanusbio.address (room_id, cage_address, room_lighting) VALUES (1, 'A1', 'Standard');
INSERT INTO sanusbio.supplier (supplier_name, contact_info) VALUES ('Internal Breeding', 'N/A');
```

**Option B — API (once logged in as admin):**
```bash
# Get your token first, then:
curl -X POST http://localhost:4000/api/addresses \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"room_id":1,"cage_address":"A1","room_lighting":"Standard"}'

curl -X POST http://localhost:4000/api/suppliers \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"supplier_name":"Internal Breeding"}'
```

---

## Troubleshooting

**Port already in use:**
```bash
sudo lsof -i :4000   # check what's using it
# If needed, change PORT in .env
```

**MySQL connection refused:**
```bash
sudo systemctl status mysql
mysql -u sanusbio_app -p -h localhost sanusbio   # test connection directly
```

**Service won't start:**
```bash
sudo journalctl -u sanusbio -n 50 --no-pager   # see full error
```

**JWT expired / login fails after restart:**
- Tokens are 8 hours. Just log in again. JWT_SECRET must stay consistent in .env.