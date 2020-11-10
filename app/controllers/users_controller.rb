class UsersController < ApplicationController

  def index
    @users = User.page(params[:page]).recent
    @page = params[:page]
    # ページネーションは非同期で作成した。作り自体はpostsの時と全く同じ
  end

  def show
    @user = User.find(params[:id])
  end

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
    # username抜けてるの気付いたんで修正しました
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
