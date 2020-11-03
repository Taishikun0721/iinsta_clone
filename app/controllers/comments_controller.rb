class CommentsController < ApplicationController
  before_action :require_login
  # ログインしてないとアクセスできない様にした。この調子でbefore_actionとかが増えてくるなら
  before_action :set_comment, only: [:edit, :update, :destroy]

  def new
    @comment = Comment.new
  end

  def create
    @comment = current_user.comments.new(comment_params)
    @comment.save
  end

  def edit; end

  def update
    @comment.update(comment_update_params)
  end

  def destroy
    @comment.destroy!
  end

  private

  def set_comment
    @comment = current_user.comments.find(params[:id])
  end

  def comment_params
    # post_idの情報はフォームから送信してくるものでは無いので、mergeメソッドで後から付与してあげる
    params.require(:comment).permit(:body).merge(post_id: params[:post_id])
  end

  def comment_update_params
    # 本来ならcomment_paramsというcreate用のストロングパラメーターを作成してそこでは外部キーの登録が必要
    # ただし、更新時はbodyだけ許可したい。だからここでは名前がcomment_update_paramsにしてbodyだけ許可している。
    params.require(:comment).permit(:body)
  end
end
