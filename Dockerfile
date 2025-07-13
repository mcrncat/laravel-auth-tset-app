# 1. Node.js環境でReactビルドのみ実行
FROM node:20 AS node-build

WORKDIR /app

# bashなど必要ツールをインストール（必要なら）
RUN apk add --no-cache bash git openssh curl zip unzip libpng-dev libxml2-dev oniguruma-dev libzip-dev

COPY package*.json ./
RUN npm install

COPY resources/js ./resources/js
COPY vite.config.ts ./
RUN npm run build   # public/build にReactのビルド成果物が生成される想定

# 2. PHP環境でComposerインストールとLaravelセットアップ
FROM php:8.1-fpm-alpine AS php-build

WORKDIR /var/www/html

RUN apk add --no-cache \
    bash git curl zip unzip libzip-dev libpng-dev libxml2-dev oniguruma-dev $PHPIZE_DEPS \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip zip

# Composerインストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Reactのビルド成果物をNodeビルドステージからコピー
COPY --from=node-build /app/public ./public

# Laravelソースコードコピー
COPY . .

# SQLiteファイル作成
RUN touch database/database.sqlite

RUN php artisan key:generate
RUN php artisan migrate --force

RUN chown -R www-data:www-data storage bootstrap/cache

# 3. 実行用軽量PHPイメージ
FROM php:8.1-fpm-alpine

WORKDIR /var/www/html

RUN apk add --no-cache libpng libzip oniguruma curl unzip

COPY --from=php-build /var/www/html /var/www/html

RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
