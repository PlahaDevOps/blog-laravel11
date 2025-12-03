FROM php:8.3-fpm

# System deps
RUN apt-get update && apt-get install -y \
    git curl unzip libzip-dev libpng-dev \
 && docker-php-ext-install pdo pdo_mysql zip gd

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy code
COPY . .

# Create required Laravel writable dirs BEFORE composer scripts run
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Now composer can run artisan scripts safely
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader

CMD ["php-fpm"]

