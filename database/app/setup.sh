#!/bin/bash

# SanusBio Setup Script
# This script helps you get started quickly

set -e

echo "🦡 SanusBio Ferret Colony Manager - Quick Setup"
echo "================================================"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL is not installed. Please install MySQL 8.0+ first."
    exit 1
fi

echo "✅ MySQL found"
echo ""

# Backend setup
echo "📦 Setting up backend..."
cd backend
npm install
echo "✅ Backend dependencies installed"
echo ""

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env with your MySQL credentials"
    echo ""
fi

# Database setup
echo "🗄️  Database setup:"
read -p "MySQL root password: " -s MYSQL_PASS
echo ""
read -p "Create database 'sanusbio'? (y/n): " CREATE_DB

if [ "$CREATE_DB" = "y" ]; then
    mysql -u root -p$MYSQL_PASS -e "CREATE DATABASE IF NOT EXISTS sanusbio;"
    echo "✅ Database created"
    
    read -p "Run schema files? (y/n): " RUN_SCHEMA
    if [ "$RUN_SCHEMA" = "y" ]; then
        if [ -f ../sanusbio_database_schema.sql ]; then
            mysql -u root -p$MYSQL_PASS sanusbio < ../sanusbio_database_schema.sql
            echo "✅ Main schema loaded"
        fi
        mysql -u root -p$MYSQL_PASS sanusbio < schema_additions.sql
        echo "✅ Additional schema loaded"
    fi
fi

# Create admin user
echo ""
read -p "Create admin user? (y/n): " CREATE_ADMIN
if [ "$CREATE_ADMIN" = "y" ]; then
    HASH=$(node -e "console.log(require('bcryptjs').hashSync('admin123', 10))")
    mysql -u root -p$MYSQL_PASS sanusbio -e "INSERT INTO users (username, password, email, role, full_name) VALUES ('admin', '$HASH', 'admin@sanusbio.com', 'admin', 'System Administrator') ON DUPLICATE KEY UPDATE username=username;"
    echo "✅ Admin user created"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo "   ⚠️  CHANGE THIS PASSWORD AFTER FIRST LOGIN!"
fi

# VAPID keys
echo ""
echo "🔐 Generating VAPID keys for push notifications..."
npx web-push generate-vapid-keys > vapid_keys.txt
echo "✅ VAPID keys generated in backend/vapid_keys.txt"
echo "   Add these to your .env file"
echo ""

# Done
echo "✅ Setup complete!"
echo ""
echo "To start the application:"
echo "  1. Backend:  cd backend && npm start"
echo "  2. Frontend: cd frontend && python3 -m http.server 5173"
echo "  3. Open:     http://localhost:5173"
echo ""
echo "First login:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "📚 See README.md for full documentation"
