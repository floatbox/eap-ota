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

end
