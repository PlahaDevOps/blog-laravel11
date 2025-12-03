FROM php:8.3-fpm

# System deps
RUN apt-get update && apt-get install -y \
    git curl unzip libzip-dev libpng-dev \
 && docker-php-ext-install pdo pdo_mysql zip gd

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy code
COPY . .

# Install PHP deps (skip scripts during build, will run later)
RUN composer install --no-interaction --prefer-dist --no-scripts

# Create Laravel directories if they don't exist and set permissions
RUN mkdir -p /var/www/storage /var/www/bootstrap/cache && \
    chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

CMD ["php-fpm"]

