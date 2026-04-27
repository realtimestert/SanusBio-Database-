# SanusBio — Local Server Setup Guide (Linux)
> No domain name required. Everything runs on `localhost`.

---

## Prerequisites Overview

| Tool | Purpose |
|---|---|
| MySQL 8.0+ | Database server |
| Python 3.10+ | Backend runtime |
| pip + virtualenv | Python package management |
| Git (optional) | Version control |

---

## Step 1 — Install MySQL

```bash
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql   # Auto-start on boot
```

**Secure the installation:**
```bash
sudo mysql_secure_installation
```
Follow the prompts: set a root password, remove anonymous users, disallow remote root login, and remove the test database.

**Verify MySQL is running:**
```bash
sudo systemctl status mysql
```

---

## Step 2 — Create the SanusBio Database

**Log into MySQL as root:**
```bash
sudo mysql -u root -p
```

**Inside the MySQL shell, create a dedicated app user (don't use root for your app):**
```sql
CREATE USER 'sanusbio_user'@'localhost' IDENTIFIED BY 'your_strong_password_here';
GRANT ALL PRIVILEGES ON sanusbio.* TO 'sanusbio_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Import the schema:**
```bash
mysql -u sanusbio_user -p < sanusbio_database_schema.sql
```

**Verify tables were created:**
```bash
mysql -u sanusbio_user -p -e "USE sanusbio; SHOW TABLES;"
```

You should see all 15 tables: `users`, `ferret_qr005`, `litter_log`, `health_event`, etc.

---

## Step 3 — Set Up Python Environment

Navigate to your project's backend folder first:
```bash
cd /path/to/your/sanusbio/backend
```

**Install virtualenv if you don't have it:**
```bash
pip3 install virtualenv
```

**Create and activate a virtual environment:**
```bash
python3 -m venv venv
source venv/bin/activate
```

Your terminal prompt should now show `(venv)` — this means you're working inside the isolated environment.

**Install dependencies.** If your project has a `requirements.txt`:
```bash
pip install -r requirements.txt
```

If there's no `requirements.txt` yet, install the common packages for a Python + MySQL web app:
```bash
pip install flask flask-sqlalchemy pymysql python-dotenv
# OR if Django:
pip install django mysqlclient python-dotenv
```

---

## Step 4 — Identify Your Framework

Run this from inside your backend folder to check:
```bash
# Look for key framework files
ls *.py | head -20
cat requirements.txt 2>/dev/null || echo "No requirements.txt found"
```

- If you see `app.py`, `run.py`, or `from flask import Flask` anywhere → **Flask**
- If you see `manage.py` or `settings.py` → **Django**

---

## Step 5 — Configure the Database Connection

Create a `.env` file in your backend root directory to store credentials safely:
```bash
nano .env
```

Paste this and fill in your values:
```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=sanusbio
DB_USER=sanusbio_user
DB_PASSWORD=your_strong_password_here
SECRET_KEY=pick_a_long_random_string_here
DEBUG=True
```

> ⚠️ **Important:** Add `.env` to your `.gitignore` so credentials are never committed to version control.

### If Flask — check your `app.py` or `config.py` for something like:
```python
from dotenv import load_dotenv
import os

load_dotenv()

app.config['SQLALCHEMY_DATABASE_URI'] = (
    f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
)
```

### If Django — check `settings.py` for:
```python
import os
from dotenv import load_dotenv
load_dotenv()

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST', 'localhost'),
        'PORT': os.getenv('DB_PORT', '3306'),
    }
}
```

---

## Step 6 — Run the App Locally

Make sure your virtual environment is active (`source venv/bin/activate`).

### Flask:
```bash
python app.py
# OR
flask run
```
App will be available at: **http://localhost:5000**

### Django:
```bash
python manage.py migrate    # Apply any pending migrations
python manage.py runserver
```
App will be available at: **http://localhost:8000**

Open that URL in your browser — your SanusBio app should load.

---

## Step 7 — Serve the Frontend

If your frontend is a separate folder (React, plain HTML/CSS/JS):

### Plain HTML/CSS/JS — serve it with Python's built-in server:
```bash
cd /path/to/your/frontend
python3 -m http.server 3000
```
Frontend available at: **http://localhost:3000**

### React — if you have Node.js installed:
```bash
cd /path/to/your/frontend
npm install
npm start
```
Frontend available at: **http://localhost:3000** (by default)

Make sure your frontend's API base URL points to `http://localhost:5000` (Flask) or `http://localhost:8000` (Django), not a production domain.

---

## Step 8 — Keep Everything Running with a Simple Start Script

Create a `start.sh` in your project root so you don't have to remember all the commands:

```bash
nano start.sh
```

```bash
#!/bin/bash
echo "Starting SanusBio locally..."

# Start MySQL if it's not already running
sudo systemctl start mysql

# Start backend
cd /path/to/your/backend
source venv/bin/activate

# Uncomment one of these:
# flask run &               # Flask
# python manage.py runserver &   # Django

echo "Backend running."

# Start frontend (if separate)
# cd /path/to/your/frontend
# python3 -m http.server 3000 &

echo "SanusBio is up at http://localhost:5000 (or :8000 for Django)"
```

Make it executable:
```bash
chmod +x start.sh
./start.sh
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Access denied for user` MySQL error | Double-check your `.env` password matches what you set in Step 2 |
| `Module not found` errors | Make sure your venv is activated: `source venv/bin/activate` |
| Port already in use | Run `sudo lsof -i :5000` to find and kill the process |
| MySQL won't start | Run `sudo journalctl -u mysql` to see error logs |
| Schema import fails | Make sure you're in the same folder as the `.sql` file when running the import command |

---

## When You Get a Domain Name

When you're ready to go live, you'll add:
- **Nginx** or **Apache** as a reverse proxy in front of Flask/Django
- **Gunicorn** (Flask) or **uWSGI** (Django) as the production WSGI server
- **Let's Encrypt / Certbot** for free HTTPS certificates

All of that is a separate step — for now, `localhost` is all you need.

---

*Last updated for SanusBio local setup — Linux / MySQL 8.0 / Python 3.10+*
