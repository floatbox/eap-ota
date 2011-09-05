# encoding: utf-8
class Admin::NotificationsController < Admin::ResourcesController
  before_filter :update_typus_user_id, :only => [:create, :update]

  def update_typus_user_id
    params[:notification][:typus_user_id] = session[:typus_user_id]
  end

end