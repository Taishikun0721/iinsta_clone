class Mypage::AccountsController < Mypage::BaseController
  def edit
    # @user = current_user
    # p @user.object_id
    # p current_user.object_id
    # 上の様に書くと同じobject_idが取得される。Rubyの変数は名札のような物で同じオブジェクトに別名をつけている状態になるので
    # userを変更した場合に、グローバルに使用されているcurrent_userに不具合が出る可能性がある。
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(current_user.id)
    if @user.update(account_params)
      redirect_to edit_mypage_account_path, success: 'プロフィール更新しました'
    else
      flash.now[:danger] = 'プロフィール更新に失敗しました'
      render :edit
    end
  end

  private

  def account_params
    params.require(:user).permit(:username, :avatar, :avatar_cache)
    # これからemailとか更新する実装もするのだろうけど、現段階ではusernameとavatarだけ許可する
  end
end
