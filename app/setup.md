# SanusBio — Local Server Setup Guide
### Raspberry Pi 4 (Raspberry Pi OS / Debian-based)

---

## Prerequisites

Before starting, make sure you have:

- A Raspberry Pi 4 (2 GB RAM minimum recommended)
- Raspberry Pi OS (64-bit recommended) installed and running
- SSH access enabled, or a keyboard/monitor connected
- An internet connection on the Pi
- The SanusBio project files copied to the Pi

---

## Step 1 — Install Node.js

SanusBio requires Node.js v18 or later. The default `apt` repositories may ship an older version, so install via NodeSource:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify the installation:

```bash
node -v   # should print v20.x.x or later
npm -v
```

---

## Step 2 — Install MySQL

```bash
sudo apt update
sudo apt install -y mysql-server
```

Start and enable MySQL so it runs on boot:

```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

Run the initial security setup (recommended):

```bash
sudo mysql_secure_installation
```

> **Tip:** When prompted, set a strong root password and answer **Y** to remove anonymous users, disallow remote root login, and remove the test database.

---

## Step 3 — Create the Database and User

Log into MySQL as root:

```bash
sudo mysql -u root -p
```

Inside the MySQL shell, run:

```sql
CREATE DATABASE sanusbio CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'sanusbio_user'@'localhost' IDENTIFIED BY 'YourStrongPassword';
GRANT ALL PRIVILEGES ON sanusbio.* TO 'sanusbio_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

> Replace `YourStrongPassword` with a secure password of your choice. You will use this in the `.env` file in Step 5.

---

## Step 4 — Import the Schema and Migrations

Navigate to the directory where your SanusBio project files are located, then run:

```bash
mysql -u sanusbio_user -p sanusbio < sanusbio_database_schema.sql
mysql -u sanusbio_user -p sanusbio < migrations.sql
```

You will be prompted for the password you created in Step 3. The first command creates all the tables; the second applies fixes and adds missing columns (such as `sex`, auto-increment keys, and the corrected phone number column type).

Verify the tables were created:

```bash
mysql -u sanusbio_user -p -e "USE sanusbio; SHOW TABLES;"
```

You should see all SanusBio tables listed (e.g., `ferret_qr005`, `users`, `health_event`, etc.).

---

## Step 5 — Configure the Environment

In the root of the SanusBio project folder, create a `.env` file:

```bash
nano .env
```

Add the following, replacing values as appropriate:

```env
PORT=4000
DB_HOST=localhost
DB_USER=sanusbio_user
DB_PASS=YourStrongPassword
DB_NAME=sanusbio
JWT_SECRET=change-this-to-a-long-random-string
```

> **Important:** Set `JWT_SECRET` to a long, random string (at least 32 characters). This secures all user login tokens. You can generate one with:
> ```bash
> node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
> ```

Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

---

## Step 6 — Install Dependencies

From the project root directory:

```bash
npm install
```

This installs all required packages listed in `package.json` (Express, MySQL2, JWT, bcryptjs, etc.).

---

## Step 7 — Create the First Admin User

SanusBio does not include a default admin account. You need to insert one manually before first login.

Generate a bcrypt hash for your chosen password:

```bash
node -e "const b=require('bcryptjs'); b.hash('YourAdminPassword',12).then(h=>console.log(h))"
```

Copy the output hash, then insert the user into MySQL:

```bash
mysql -u sanusbio_user -p sanusbio
```

```sql
INSERT INTO users (username, password, email, role, full_name, active)
VALUES (
  'admin',
  '$2a$12$YOUR_HASH_HERE',
  'admin@example.com',
  'admin',
  'Administrator',
  1
);
EXIT;
```

> Replace `$2a$12$YOUR_HASH_HERE` with the hash generated above.

---

## Step 8 — Start the Server

```bash
node server.js
```

You should see:

```
🐾 SanusBio running → http://localhost:4000
   Roles: admin > research > maternity > caretaker
```

Open a browser on the same network and navigate to:

```
http://<your-pi-ip-address>:4000
```

> Find your Pi's IP address with: `hostname -I`

Log in with the admin credentials you created in Step 7.

---

## Step 9 — Run SanusBio Automatically on Boot

To keep SanusBio running after reboot or SSH disconnection, set it up as a `systemd` service.

Create the service file:

```bash
sudo nano /etc/systemd/system/sanusbio.service
```

Paste the following (update `WorkingDirectory` and `User` to match your setup):

```ini
[Unit]
Description=SanusBio Ferret Research Management Server
After=network.target mysql.service

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/sanusbio
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
EnvironmentFile=/home/pi/sanusbio/.env

[Install]
WantedBy=multi-user.target
```

> Replace `/home/pi/sanusbio` with the actual path to your project folder, and `pi` with your actual username (check with `whoami`).

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable sanusbio
sudo systemctl start sanusbio
```

Check that it is running:

```bash
sudo systemctl status sanusbio
```

You should see `Active: active (running)`.

---

## Useful Commands

| Task | Command |
|---|---|
| Start the server | `sudo systemctl start sanusbio` |
| Stop the server | `sudo systemctl stop sanusbio` |
| Restart the server | `sudo systemctl restart sanusbio` |
| View live logs | `sudo journalctl -u sanusbio -f` |
| Check server status | `sudo systemctl status sanusbio` |
| Find Pi IP address | `hostname -I` |

---

## Troubleshooting

**Cannot connect to MySQL**
- Confirm MySQL is running: `sudo systemctl status mysql`
- Double-check `DB_USER`, `DB_PASS`, and `DB_NAME` in your `.env` file

**Port 4000 is already in use**
- Change `PORT` in `.env` to another value (e.g., `4001`) and restart

**`node: command not found` in systemd**
- Find the full path with `which node` and use that in `ExecStart`

**Login fails after creating admin user**
- Confirm the bcrypt hash was inserted correctly: `SELECT username, role FROM users;`
- Ensure `active = 1` on the user row

---

*SanusBio v1.3 — Last updated 2026-05-04*