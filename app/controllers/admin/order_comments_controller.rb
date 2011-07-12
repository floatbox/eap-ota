# encoding: utf-8
class Admin::OrderCommentsController < Admin::ResourcesController
  before_filter :update_typus_user_id, :only => [:create, :update]
   
  def update_typus_user_id
    params[:order_comment][:typus_user_id] = session[:typus_user_id]
  end
  
end