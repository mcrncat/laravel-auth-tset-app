# 1. Node.js環境でReactビルドのみ実行
FROM node:20 AS node-build

WORKDIR /app

# 必要パッケージのインストール（Debian）
RUN apt-get update && \
    apt-get install -y bash git openssh curl zip unzip libpng-dev libxml2-dev libonig-dev libzip-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# パッケージインストール
COPY package*.json ./
RUN npm install

# React ソースと Vite 設定のコピー
COPY resources/js ./resources/js
COPY vite.config.js ./  # ← `.ts` の場合は事前に対処する
RUN npm run build

# 2. PHP環境でComposerインストールとLaravelセットアップ
FROM php:8.1-fpm AS php-build

WORKDIR /var/www/html

RUN apt-get update && \
    apt-get install -y bash git openssh curl zip unzip libpng-dev libxml2-dev libonig-dev libzip-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Laravel依存ファイルのインストール
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Reactビルド成果物をコピー
COPY --from=node-build /app/public/build ./public/build

# Laravelソースコピー
COPY . .

# SQLite ファイル
RUN touch database/database.sqlite

# Laravel初期化
RUN php artisan key:generate
RUN php artisan migrate --force

# 権限
RUN chown -R www-data:www-data storage bootstrap/cache

# 3. 実行用軽量PHPイメージ
FROM php:8.1-fpm

WORKDIR /var/www/html

RUN apt-get update && \
    apt-get install -y libpng-dev libzip-dev libonig-dev curl unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 最終アプリをコピー
COPY --from=php-build /var/www/html /var/www/html

# 権限
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
