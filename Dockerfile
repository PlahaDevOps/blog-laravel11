FROM php:8.3-fpm

# System deps
RUN apt-get update && apt-get install -y \
    git curl unzip libzip-dev libpng-dev \
 && docker-php-ext-install pdo pdo_mysql zip gd

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Use default PHP web root
WORKDIR /var/www/html

# Create dirs so Docker can mount volumes cleanly
RUN mkdir -p /var/www/html/vendor \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

# Copy code
COPY . .

# Install PHP deps (skip scripts during build, will run later)
RUN composer install --no-interaction --prefer-dist --no-scripts

CMD ["php-fpm"]

