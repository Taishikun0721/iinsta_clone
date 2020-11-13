class RelationshipsController < ApplicationController
  def create
    # link_toで送信したパラメーターをここでうける。
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
  end

  def destroy
    # followdメソッドでフォローされている人は取ってくるbelongs_toで定義
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
  end
end
