class ApplicationMailer < ActionMailer::Base
  # fromにデフォルトのメールアドレスを設定。現場Railsにも書いていたが、複数のメール送信機能を持つ場合
  # 一つのメールアドレスから送る事が一般的らしい
  default from: 'instaclone@example.com'
  layout 'mailer'
end
