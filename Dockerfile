# ベースイメージ（PHP 8.2 CLI）
FROM php:8.2-cli

# 必要パッケージのインストールとPHP拡張ビルド
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    zip \
    sqlite3 \
    libsqlite3-dev \
    libonig-dev \
    nodejs \
    npm \
    && docker-php-source extract \
    && docker-php-ext-install pdo pdo_sqlite zip mbstring tokenizer xml ctype \
    && docker-php-source delete

# composerインストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 作業ディレクトリ設定
WORKDIR /var/www/html

# composerファイルを先にコピーし依存解決
COPY composer.json composer.lock ./

# composer依存関係インストール（本番向け）
RUN composer install --no-dev --optimize-autoloader

# npmファイルをコピーして依存インストール
COPY package.json package-lock.json ./
RUN npm install

# 全ファイルコピー
COPY . .

# .env準備（本番では環境変数設定推奨）
RUN cp .env.example .env

# SQLite用DBファイル作成
RUN touch database/database.sqlite

# アプリキー生成＆マイグレーション実行
RUN php artisan key:generate
RUN php artisan migrate --force

# npmビルド（Viteなど）
RUN npm run build

# Viteのmanifestをpublic/buildにコピー（必要に応じて）
RUN mkdir -p public/build && cp public/.vite/manifest.json public/build/

# 8000番ポート開放（好きなポートでOK）
EXPOSE 8000

# サーバ起動コマンド
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
