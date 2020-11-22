class ApplicationController < ActionController::Base
  # フラッシュメッセージのキーを許可する表示設定。Bootstrapはデフォルトではnoticeとsuccessしか許可していないらしい。
  before_action :set_search_posts_form
  add_flash_types :success, :info, :warning, :danger

  private

  def set_search_posts_form
    @search_form = SearchPostsForm.new(search_post_params)
  end

  def search_post_params
    # 普通にrequire(:search_posts_form)で指定してしまうと、application_controllerが呼び出された時点で、エラーになってしまう。
    # SearchPostsFormクラスがまだ読み込まれていないため
    params.fetch(:q, {}).permit(:body, :comment_body, :username_body)
  end
end
