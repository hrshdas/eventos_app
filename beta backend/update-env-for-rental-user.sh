#!/bin/bash
sed -i 's|DATABASE_URL="postgresql://postgres:postgres@localhost:5432/rental_marketplace?schema=public"|DATABASE_URL="postgresql://rental_user:rental_pass123@localhost:5432/rental_marketplace?schema=public"|' .env
echo "Updated .env to use rental_user"
