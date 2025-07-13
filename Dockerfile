# ベースイメージ
FROM php:8.1-cli

# システム依存パッケージをインストール
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    zip \
    sqlite3 \
    libsqlite3-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_sqlite zip

# 作業ディレクトリ
WORKDIR /var/www/html

# composerをインストール（もしローカルにcomposer.pharがなければ）
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ソースコードをコピー（先にcomposer.jsonとpackage.jsonだけコピーするとキャッシュ効率UP）
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./

# PHP依存関係インストール
RUN composer install --no-dev --optimize-autoloader

# Node.js依存関係インストール
RUN npm install

# 全コードをコピー
COPY . .

# 環境設定ファイルをコピー
RUN cp .env.example .env

# SQLite DBファイル作成
RUN touch database/database.sqlite

# Laravelキー生成とマイグレーション
RUN php artisan key:generate
RUN php artisan migrate --force

# フロントビルド（Viteなど）
RUN npm run build

# manifest.jsonをpublic/buildにコピー（必要なら）
RUN mkdir -p public/build && cp public/.vite/manifest.json public/build/

# ポート開放
EXPOSE 10000

# サーバ起動コマンド（Renderのポート指定に合わせる）
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
