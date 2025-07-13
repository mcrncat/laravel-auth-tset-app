FROM php:8.2-fpm

# 必要パッケージのインストール
RUN apt-get update && apt-get install -y \
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

# composer インストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 作業ディレクトリ設定
WORKDIR /var/www/html

# プロジェクト全体をコピー
COPY . .

# composer依存関係インストール（本番環境向け）
RUN composer install --no-dev --optimize-autoloader

# npm依存関係インストール
RUN npm install

# .envファイル準備
RUN cp .env.example .env

# SQLite用DBファイル作成
RUN touch database/database.sqlite

# アプリケーションキー生成
RUN php artisan key:generate

# マイグレーション実行（本番環境は --force 付けるのが推奨）
RUN php artisan migrate --force

# npmビルド（Vite等）
RUN npm run build
RUN ls -a public/build/.vite/
# Vite manifestのコピー（必要に応じて）
RUN cp public/.vite/manifest.json public/build/

# ポート公開
EXPOSE 8000

# サーバ起動コマンド
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
