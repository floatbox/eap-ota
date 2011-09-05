# encoding: utf-8
class Admin::OrderCommentsController < Admin::ResourcesController
  before_filter :update_typus_user_id, :only => [:create, :update]

  def update_typus_user_id
    params[:order_comment][:typus_user_id] = session[:typus_user_id]
  end

  def index
    # так тоже можно. просто выставляет параметры обычных фильтров
    add_predefined_filter 'Assigned To Me', {:assigned_to_id => admin_user.id, :status => 'не обработан'}
    super
  end
  
end
