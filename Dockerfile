FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Configure apt and install dependencies
RUN apt-get update || true \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    libxml2-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_pgsql pgsql mbstring zip exif pcntl bcmath

# Skip PostGIS PHP extension for now as it's causing issues
# We can add spatial functionality through Laravel packages without it

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

# No final do seu Dockerfile
ARG WWWUSER=1000
ARG WWWGROUP=1000

# Criar usuário não-root com seus IDs
RUN groupmod -o -g ${WWWGROUP} www-data && \
    usermod -o -u ${WWWUSER} -g www-data www-data

# Alterar permissões do diretório de trabalho
RUN chown -R www-data:www-data /var/www
USER www-data

CMD ["php-fpm"]