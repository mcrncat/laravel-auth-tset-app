FROM php:8.2-fpm

# Node.js v20 を公式からインストール（Vite 7対応）
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    zip \
    sqlite3 \
    libsqlite3-dev \
    libonig-dev \
    libxml2-dev \
    nodejs \
    npm

# PHP拡張インストール
RUN docker-php-ext-install pdo pdo_sqlite zip mbstring xml ctype

# Composer インストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 作業ディレクトリ設定
WORKDIR /var/www/html

# プロジェクト全体をコピー
COPY . .

# SQLite DBファイル作成
RUN mkdir -p database && touch database/database.sqlite

# .env を配置
RUN cp .env.product .env

# アプリケーションキー生成
RUN php artisan key:generate

# Composer依存関係インストール（本番環境向け）
RUN composer install --no-dev --optimize-autoloader

# npm 依存関係インストール
RUN npm install

# Viteビルド
RUN npm run build

# manifest.json をコピー
RUN cp public/build/.vite/manifest.json public/build/manifest.json

# Laravel 設定キャッシュ & マイグレーション
RUN php artisan config:clear \
    && php artisan config:cache \
    && php artisan migrate --force

# ポート公開
EXPOSE 8000

# アプリケーション起動
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
