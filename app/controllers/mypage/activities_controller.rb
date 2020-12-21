class Mypage::ActivitiesController < Mypage::BaseController
  # Basecontrollerでbefore_action :require_loginしてるから書かなかった。
  def index
    @activities = current_user.activities.page(params[:page]).per(10)
  end
end
