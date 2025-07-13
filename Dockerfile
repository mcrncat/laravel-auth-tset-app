FROM php:8.2-fpm-alpine

# 基本パッケージ
RUN apk add --no-cache \
    nginx \
    git \
    unzip \
    curl \
    libzip-dev \
    zip \
    sqlite \
    sqlite-dev \ 
    oniguruma-dev \
    libxml2-dev \
    nodejs \
    npm \
    supervisor \
    bash


# PHP拡張
RUN docker-php-ext-install pdo pdo_sqlite zip mbstring xml

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 作業ディレクトリ
WORKDIR /var/www/html

# プロジェクトコピー
COPY . .

# Laravel初期セットアップ
RUN composer install --no-dev --optimize-autoloader && \
    cp .env.product .env && \
    php artisan key:generate && \
    touch database/database.sqlite && \
    php artisan migrate --force && \
    php artisan config:cache

# Laravelのキャッシュディレクトリに書き込み権限を付与
RUN chmod -R 775 storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache


# Viteビルド
RUN npm install && npm run build && \
    cp public/build/.vite/manifest.json public/build/

# nginx設定ファイル
COPY ./docker/nginx/default.conf /etc/nginx/http.d/default.conf

# supervisor設定（php-fpm と nginx の両方を起動）
COPY ./docker/supervisord.conf /etc/supervisord.conf

# ポート公開
EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
