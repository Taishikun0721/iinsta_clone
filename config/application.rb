require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module InstaClone
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # Railsのタイムゾーンを指定する。
    # またアプリのデフォルトの言語を日本語にする。
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    # 実際に非同期処理を行うのはsidekiqで、Active_jobはそのインターフェースを準備してるだけなので、ここでは、どの非同期処理ツールを使うか設定している。
    config.active_job.queue_adapter = :sidekiq
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
