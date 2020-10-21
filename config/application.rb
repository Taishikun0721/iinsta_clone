require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module InstaClone
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.autoload_paths += Dir[Rails.root.join('app', 'uploaders')]

    # Railsのタイムゾーンを指定する。
    # またアプリのデフォルトの言語を日本語にする。
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # 各ファイルが自動生成されない様に設定する。テスト・JS・CSSだけの指示だがルーティングとヘルパーもいらないので指定。
    config.generators do |g|
      g.assets false
      g.skip_routes true
      g.test_framework false
      g.helper false
    end
  end
end
