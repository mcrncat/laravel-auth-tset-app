FROM php:8.1-cli

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
    && docker-php-ext-install pdo pdo_sqlite zip mbstring tokenizer xml ctype

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./

RUN composer --version

RUN composer install --no-dev --optimize-autoloader

COPY package.json package-lock.json ./
RUN npm install

COPY . .

RUN cp .env.example .env

RUN touch database/database.sqlite

RUN php artisan key:generate
RUN php artisan migrate --force

RUN npm run build

RUN mkdir -p public/build && cp public/.vite/manifest.json public/build/

EXPOSE 10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
