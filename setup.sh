#!/bin/bash

# Script para configurar o ambiente Laravel 12 com PostgreSQL e PostGIS

# Criar diretórios necessários se não existirem
mkdir -p nginx/conf.d
mkdir -p nginx/ssl
mkdir -p php
mkdir -p postgres/init-scripts

# Criar certificados SSL autoassinados
echo "Gerando certificados SSL autoassinados..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/self-signed.key \
  -out nginx/ssl/self-signed.crt \
  -subj "/CN=localhost"

# Criar arquivo de configuração PHP
echo "Configurando PHP..."
cat > php/local.ini << 'EOF'
upload_max_filesize=40M
post_max_size=40M
memory_limit=512M
EOF

# Criar script de inicialização para habilitar PostGIS no PostgreSQL
echo "Configurando PostGIS no PostgreSQL..."
cat > postgres/init-scripts/init-postgis.sql << 'EOF'
-- Habilita a extensão PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOF

# Caso não exista projeto Laravel, criar um novo com Composer
if [ ! -d "../vbuz-webserver" ]; then
  echo "Criando um novo projeto Laravel 12..."
  vbuz-infra run --rm -v $(pwd)/..:/app composer create-project --prefer-dist laravel/laravel vbuz-webserver
  
  # Configurar .env para PostgreSQL com PostGIS
  sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=pgsql/g' ../vbuz-webserver/.env
  sed -i 's/DB_HOST=127.0.0.1/DB_HOST=db/g' ../vbuz-webserver/.env
  sed -i 's/DB_PORT=3306/DB_PORT=5432/g' ../vbuz-webserver/.env
  sed -i 's/DB_DATABASE=laravel/DB_DATABASE=laravel/g' ../vbuz-webserver/.env
  sed -i 's/DB_USERNAME=root/DB_USERNAME=laravel/g' ../vbuz-webserver/.env
  sed -i 's/DB_PASSWORD=/DB_PASSWORD=secret/g' ../vbuz-webserver/.env
fi

echo "Configuração concluída! Execute 'docker-compose up -d' para iniciar o ambiente."