class UserMailer < ApplicationMailer
  def follow
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    mail(to: @user_to, subject: "#{@user_from.username}さんがあなたをフォローしました")
  end

  def comment_post
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    @comment = params[:comment]
    mail(to: @user_to, subject: "#{@user_from.username}さんがあなたの投稿にコメントしました")
  end

  def like_post
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    @post = params[:post]
    mail(to: @user_to, subject: "#{@user_from.username}さんがあなたの投稿にいいねしました")
  end
end
