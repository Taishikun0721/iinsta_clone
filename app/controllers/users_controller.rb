class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # ユーザー登録してもう一度ログインするのもおかしいのでauto_loginで同時にログイン
      auto_login(@user)
      redirect_to login_path, success: 'ユーザーを作成しました。'
    else
      flash.now[:danger] = 'ユーザーの作成に失敗しました。'
      render :new
    end
  end

  private

  def user_params
    # 抜けてるの気付いたんで修正しました
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
