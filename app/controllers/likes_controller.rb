class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    @post = current_user.like(post)
  end

  def destroy
    # パーシャルでpostの情報を使うので親のpostを撮ってきている。ただ削除を実現するだけなら普通にlikeのidをとってきてdestroyでも可能。しかしviewに反映させる術が無い
    post = Like.find(params[:id]).post
    @post = current_user.unlike(post)
  end
end

# モデルでreloadさせて数値を取得したいので、ローカル変数とインスタンス変数で分けている