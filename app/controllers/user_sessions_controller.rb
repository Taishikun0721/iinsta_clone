class UserSessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      # 例えば詳細ページまで閲覧可能で、詳細ページからログイン画面に遷移してしまった場合、ログイン後は、詳細ページにリダイレクトする。
      # redirectなのでflash.nowは使用しない。次のリクエストでメッセージでフラッシュメッセージを出すため。
      redirect_back_or_to root_path, success: 'ログインしました。'
    else
      # renderなのでflash.nowを使う。flash.nowは現在のリクエスト内で表示する。
      flash.now[:danger] = 'ログインに失敗しました。'
      render :new
    end
  end

  def destroy
    logout
    redirect_to root_path, success: 'ログアウトしました'
  end
end
