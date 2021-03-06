# encoding: utf-8
class Admin::EviterraResourceController < Admin::ResourcesController

  def admin_user
    current_deck_user
  end

  def authenticate
    authenticate_deck_user!
  end

  def admin_sign_out_path
    destroy_deck_user_session_path
  end
  helper_method :admin_sign_out_path

  def user_for_paper_trail
    admin_user && admin_user.email
  end

  def info_for_paper_trail
    { :done => "#{params[:controller]}/#{params[:action]}" }
  end

  before_filter :log_admin_user
  def log_admin_user
    logger.info "AdminUser: #{admin_user.email}"
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
