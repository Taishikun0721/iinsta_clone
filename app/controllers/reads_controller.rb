class ReadsController < ApplicationController
  def create
    activity = current_user.activities.find(params[:activity_id])
    activity.read! if activity.unread?
    redirect_to activity.redirect_path
  end
end
