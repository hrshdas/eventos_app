# Database Setup Guide

## PostgreSQL Installation

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verify installation
psql --version
```

### macOS (using Homebrew)

```bash
# Install PostgreSQL
brew install postgresql@14

# Start PostgreSQL service
brew services start postgresql@14

# Verify installation
psql --version
```

### Create Database and User

After installing PostgreSQL, create the database and user:

```bash
# Switch to postgres user
sudo -u postgres psql

# Or if on macOS with Homebrew:
psql postgres
```

Then run these SQL commands:

```sql
-- Create database
CREATE DATABASE rental_marketplace;

-- Create user (optional - you can use postgres user for development)
CREATE USER rental_user WITH PASSWORD 'your_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE rental_marketplace TO rental_user;

-- Exit
\q
```

## Configure Environment Variables

Update your `.env` file with the correct database URL:

```env
# For default postgres user (development)
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/rental_marketplace?schema=public"

# Or for custom user
DATABASE_URL="postgresql://rental_user:your_password@localhost:5432/rental_marketplace?schema=public"
```

## Run Prisma Migrations

After setting up the database:

```bash
# Generate Prisma Client
npm run prisma:generate

# Run migrations to create tables
npm run prisma:migrate

# You'll be prompted to name the migration (e.g., "init")
```

## Verify Connection

Test the connection:

```bash
# Using psql
psql -h localhost -U postgres -d rental_marketplace

# Or test with Prisma Studio
npm run prisma:studio
```

## Troubleshooting

### PostgreSQL not starting

```bash
# Check status
sudo systemctl status postgresql

# Start service
sudo systemctl start postgresql

# Check logs
sudo journalctl -u postgresql
```

### Connection refused

- Ensure PostgreSQL is running: `sudo systemctl status postgresql`
- Check if port 5432 is open: `netstat -tuln | grep 5432`
- Verify `pg_hba.conf` allows local connections

### Permission denied

- Ensure the database user has proper permissions
- Check PostgreSQL authentication settings in `pg_hba.conf`

## Quick Start (All-in-One)

If you just want to get started quickly:

```bash
# 1. Install PostgreSQL (Ubuntu/Debian)
sudo apt update && sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql

# 2. Create database
sudo -u postgres psql -c "CREATE DATABASE rental_marketplace;"

# 3. Update .env (use default postgres user for dev)
# DATABASE_URL="postgresql://postgres:postgres@localhost:5432/rental_marketplace?schema=public"

# 4. Run migrations
npm run prisma:generate
npm run prisma:migrate

# 5. Start server
npm run dev
```

