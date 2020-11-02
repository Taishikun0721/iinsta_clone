class CommentsController < ApplicationController
  before_action :require_login
  # ログインしてないとアクセスできない様にした。この調子でbefore_actionとかが増えてくるなら

  def new
    @comment = Comment.new
  end

  def create
    # パRailsで学んだ書き方を使用してみた！けど普通にストロングパラメーターで書いた方がシンプルですね！
    post = Post.find(params[:post_id])
    @comment = current_user.comments.new do |comment|
      comment.post = post
      comment.body = params[:comment][:body]
    end
    @comment.save
  end

  def edit
    set_comment(params[:id])
  end

  def update
    set_comment(params[:id])
    @comment.update(comment_update_params)
  end

  def destroy
    set_comment(params[:id])
    @comment.destroy!
  end

  private

  def set_comment(id)
    @comment = current_user.comments.find(id)
    # before_actionが肥大化してきたら嫌なのでメソッド内で呼び出す様にしてみた。それかbefore_actionをどこかにまとめて切り出せる方法とかってあるんですか？？
  end

  def comment_update_params
    # 本来ならcomment_paramsというcreate用のストロングパラメーターを作成してそこでは外部キーの登録が必要
    # ただし、更新時はbodyだけ許可したい。だからここでは名前がcomment_update_paramsにしてbodyだけ許可している。
    params.require(:comment).permit(:body)
  end
end
