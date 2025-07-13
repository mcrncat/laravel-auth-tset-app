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

# ルートリスト確認
php artisan route:list

  GET|HEAD  / .......................................................................................... 
  GET|HEAD  api/user ...................................................................................  
  GET|HEAD  confirm-password ................ password.confirm › Auth\ConfirmablePasswordController@show  
  POST      confirm-password .................................. Auth\ConfirmablePasswordController@store  
  GET|HEAD  dashboard ........................................................................ dashboard  
  POST      email/verification-notification verification.send › Auth\EmailVerificationNotificationContr…  
  GET|HEAD  forgot-password ................. password.request › Auth\PasswordResetLinkController@create  
  POST      forgot-password .................... password.email › Auth\PasswordResetLinkController@store  
  GET|HEAD  login ................................... login › Auth\AuthenticatedSessionController@create  
  POST      login ............................................ Auth\AuthenticatedSessionController@store  
  POST      logout ................................ logout › Auth\AuthenticatedSessionController@destroy  
  PUT       password .................................. password.update › Auth\PasswordController@update  
  GET|HEAD  profile .............................................. profile.edit › ProfileController@edit  
  PATCH     profile .......................................... profile.update › ProfileController@update  
  DELETE    profile ........................................ profile.destroy › ProfileController@destroy  
  GET|HEAD  register ................................... register › Auth\RegisteredUserController@create  
  POST      register ............................................... Auth\RegisteredUserController@store  
  POST      reset-password ........................... password.store › Auth\NewPasswordController@store  
  GET|HEAD  reset-password/{token} .................. password.reset › Auth\NewPasswordController@create  
  GET|HEAD  sanctum/csrf-cookie ...... sanctum.csrf-cookie › Laravel\Sanctum › CsrfCookieController@show  
  GET|HEAD  storage/{path} ............................................................... storage.local  
  GET|HEAD  up .........................................................................................  
  GET|HEAD  verify-email .................. verification.notice › Auth\EmailVerificationPromptController  
  GET|HEAD  verify-email/{id}/{hash} ....