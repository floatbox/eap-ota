# encoding: utf-8
class Admin::EviterraResourceController < Admin::ResourcesController

  def user_for_paper_trail
    admin_user && admin_user.email
  end

  # копия из application_controller, для хоптода
  # TODO вынести в отдельный модуль?
  before_filter :set_admin_user_for_airbrake
  def set_admin_user_for_airbrake
    request.env['eviterra.admin_user'] = admin_user.email if admin_user
  end

  # патчим редирект после сохранения на show
  def redirect_on_success
    path = params.dup.cleanup

    options = if params[:_save]
      # переход на show, а не на индекс
      { :action => 'show', :id => @item.id }
    elsif params[:_addanother]
      { :action => 'new', :id => nil }
    elsif params[:_continue]
      { :action => 'edit', :id => @item.id }
    end

    message = params[:action].eql?('create') ? "%{model} successfully created." : "%{model} successfully updated."
    notice = Typus::I18n.t(message, :model => @resource.model_name.human)

    redirect_to path.merge!(options).compact, :notice => notice
  end

end
