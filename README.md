# 初回コマンド

composer install 
npm install

touch database/database.sqlite
cp .env.example .env

php artisan migrate
php artisan key:generate

# 起動

php artisan serve
npm run dev