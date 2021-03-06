# encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include PartnerTracking
  has_mobile_fu false

  before_filter :set_locale
  after_filter :log_partner

  protected

  def admin_user
    current_deck_user
  end

  helper_method :admin_user
  # показывает данные текущего пользователя тайпус в админке
  alias_method :current_member, :admin_user

  def set_locale
    I18n.locale = cookies[:language].presence || :ru
  end

  def log_user_agent
    logger.info "UserAgent: #{request.user_agent}"
  end

  def after_sign_in_path_for(resource)
    case resource
    when Customer
      profile_path
    when Deck::User
      # deck_dashboard_path
      admin_dashboard_index_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def enforce_timeout
    # around_filter :enforce_timeout, only: [:pricer, :api]
    if Conf.site.enforce_timeout
      Timeout.timeout(30) do
        yield
      end
    else
      yield
    end
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end
end

