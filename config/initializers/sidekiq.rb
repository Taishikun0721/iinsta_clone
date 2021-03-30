Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis.url }
end

Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis.url }
end

# sidekiqとredisを連携させている。redisサーバーが起動しているURLとポート番号を指定している。