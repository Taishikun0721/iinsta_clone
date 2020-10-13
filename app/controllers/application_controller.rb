class ApplicationController < ActionController::Base
  # フラッシュメッセージのキーを許可する表示設定。Bootstrapはデフォルトではnoticeとsuccessしか許可していないらしい。
  add_flash_types :success, :info, :warning, :danger
end
