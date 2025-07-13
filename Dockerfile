# ---- PHPステージ ----
FROM php:8.2-fpm AS php

RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev zip sqlite3 libsqlite3-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_sqlite zip mbstring xml

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN cp .env.product .env
RUN php artisan key:generate
RUN touch database/database.sqlite
RUN php artisan migrate --force
RUN php artisan config:cache

# ---- nginxステージ ----
FROM nginx:alpine

COPY --from=php /var/www/html /var/www/html
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# php-fpmは別プロセスとして起動
COPY --from=php /usr/local/etc/php-fpm.d/ /usr/local/etc/php-fpm.d/
COPY --from=php /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
