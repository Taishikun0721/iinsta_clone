class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    @post = if current_user.like(post)
              UserMailer.with(user_from: current_user, user_to: post.user, post: post).like_post.deliver_later
              post
              # @postに代入する為に最後にpostを追加(counter_cultureを使ってたのでモデルでreloadしてるから)
              # deliver_laterは非同期処理をする場合に記述する。deliver_nowはその場ですぐに送る。
            end
  end

  def destroy
    # パーシャルでpostの情報を使うので親のpostを撮ってきている。ただ削除を実現するだけなら普通にlikeのidをとってきてdestroyでも可能。しかしviewに反映させる術が無い
    post = Like.find(params[:id]).post
    @post = current_user.unlike(post)
  end
end
