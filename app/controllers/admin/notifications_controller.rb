# encoding: utf-8
class Admin::NotificationsController < Admin::EviterraResourceController
  before_filter :update_typus_user_id, :only => [:create, :update]

  def update_typus_user_id
    params[:notification][:typus_user_id] = session[:typus_user_id]
  end

  def show_sent_notice
    notice = Notification.find(params[:id])
    render :text => notice.rendered_message
  end

end
