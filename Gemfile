source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# HTMLを効率よく書くためにslimを導入
# また既存のerbファイルを変換するためにhtml2slimを導入。最初に使用したら必要ないので削除する。
gem 'slim-rails'

# 国際化対応のためにrails-i18nを導入
gem 'rails-i18n', '~> 5.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
# ログイン認証用にsorceryを導入
gem 'sorcery'
gem 'redis-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # テスト環境でFactorybotをするとしてもdevelopmentだけじゃなくて、testにも入れた方が良いのかな。。
  gem 'faker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Rails・Rubyの構文をチェックするためにrubocopを導入
  # rubocop-paperformanceとrubocop-rspecというのもあったので調べてみる
  gem 'rubocop', require: false
  gem 'rubocop-rails' , require: false
  # better_errorsを導入して、エラー画面を見やすくする。
  # binding_of_callerでエラー画面でコンソールを使用できる様にする。
  # ちょっと開いて使ってみたが、めちゃ良さそうだった。もっと早くから入れていたらよかった。。
  gem 'better_errors'
  gem 'binding_of_caller'
  # pry-byebugを導入して、binding.pry(ブレイクポイント)を埋め込める様にする。
  # pry-railsでそこからnextを使える様にして、1行ずつ処理を進められる様にする。
  # byebugとpry-byebugは何が違うのか調べてみよう。
  gem 'pry-byebug'
  gem 'pry-rails'
  # annotateを導入して、各モデルのスキーマ情報をモデルに書き出す。routes.rbにルーティング情報を書き出してくれる機能もあるらしい。。Rubymineだからそれは今回使わない
  # あと、development環境でしか使わないからここに入れたが場所はあってるかな。。
  gem 'annotate'
  # Bootstrapの依存関係解消のためにjquery-railsとpopper_jsを導入
  gem 'jquery-rails'
  gem 'popper_js'
  gem 'font-awesome-sass', '~> 5.2.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
