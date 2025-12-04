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
RUN mkdir -p storage/framework/views \
    storage/framework/cache \
    storage/framework/sessions \
    storage/logs \
    bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Set minimal environment variables for Laravel to bootstrap during package discovery
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV APP_KEY=
ENV DB_CONNECTION=mysql
ENV DB_HOST=127.0.0.1
ENV DB_PORT=3306
ENV DB_DATABASE=laravel
ENV DB_USERNAME=root
ENV DB_PASSWORD=

# Create minimal .env file (needed for artisan commands during composer install)
# This prevents errors when package:discover runs during post-autoload-dump
RUN if [ -f .env.example ]; then \
    cp .env.example .env; \
    else \
    echo "APP_NAME=Laravel" > .env && \
    echo "APP_ENV=production" >> .env && \
    echo "APP_KEY=" >> .env && \
    echo "APP_DEBUG=false" >> .env && \
    echo "APP_URL=http://localhost" >> .env && \
    echo "LOG_CHANNEL=stack" >> .env && \
    echo "LOG_LEVEL=debug" >> .env && \
    echo "DB_CONNECTION=mysql" >> .env && \
    echo "DB_HOST=127.0.0.1" >> .env && \
    echo "DB_PORT=3306" >> .env && \
    echo "DB_DATABASE=laravel" >> .env && \
    echo "DB_USERNAME=root" >> .env && \
    echo "DB_PASSWORD=" >> .env; \
    fi

# Install composer dependencies with scripts (package discovery will run)
# Using --no-scripts as fallback if the above fails due to package discovery issues
RUN composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader --no-scripts && \
    php artisan package:discover --ansi

CMD ["php-fpm"]

