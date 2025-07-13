# 1. ビルドステージ：Node.js環境でnpmビルド＆Composer依存解決
FROM node:16-alpine AS build

WORKDIR /app

# bash, gitなどをインストール（必要に応じて）
RUN apk add --no-cache bash git openssh curl zip unzip libpng-dev libxml2-dev oniguruma-dev libzip-dev

# PHP関連パッケージと拡張のインストール用ツール（後で使う）
RUN apk add --no-cache $PHPIZE_DEPS

# Composerインストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ソースコードと依存ファイルをコピー
COPY . .

# Composer依存解決（開発依存なし）
RUN composer install --no-dev --optimize-autoloader

# npmパッケージインストール＆本番ビルド
RUN npm install
RUN npm run build   # ここでpublicディレクトリにReactの静的ファイルが生成される想定

RUN cp public/build/.vite/manifest.json public/build

# SQLite用にファイル作成（必要に応じて）
RUN touch database/database.sqlite

# Laravelアプリキー生成
RUN php artisan key:generate

# 2. ランタイムステージ：軽量PHPランタイムにビルド成果物をコピー
FROM php:8.1-fpm-alpine

WORKDIR /var/www/html

# PHP実行に必要なパッケージと拡張をインストール
RUN apk add --no-cache libpng libzip oniguruma curl unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# ビルドステージからアプリコードを丸ごとコピー（publicにReactのビルド成果物含む）
COPY --from=build /app /var/www/html

# ストレージとキャッシュの権限設定
RUN chown -R www-data:www-data storage bootstrap/cache

# ポート開放
EXPOSE 8000

# 起動コマンド
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
