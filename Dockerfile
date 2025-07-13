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

# composer依存関係インストール（vendorディレクトリ作成）
RUN composer install --no-dev --optimize-autoloader

# .envファイル準備（適宜ファイル名を変えてください）
RUN cp .env.product .env

# アプリケーションキー生成（vendorが存在するので実行可能）
RUN php artisan key:generate

# SQLite用DBファイル作成（もしなければ）
RUN touch database/database.sqlite

# 設定キャッシュクリア＆生成（本番向け）
RUN php artisan config:clear && php artisan config:cache

# マイグレーション実行（本番環境は --force 推奨）
RUN php artisan migrate --force

# npm依存関係インストール
RUN npm install

# npmビルド（Viteビルド）
RUN npm run build

# ポート公開（artisan serve 用）
EXPOSE 8000

# サーバ起動コマンド
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
