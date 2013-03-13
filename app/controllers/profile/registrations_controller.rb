class Profile::RegistrationsController < Devise::RegistrationsController

  layout "profile"

  def create
    hash ||= params[resource_name] || {}
    self.resource = resource_class.find_by_email(hash[:email])
    if resource.nil?
      super
    elsif !resource.confirmed?
      resource.send_confirmation_instructions
      respond_with resource, :location => after_inactive_sign_up_path_for(resource)
    else
      respond_with resource, :location => after_inactive_sign_up_path_for(resource)
    end     
  end

  def success
  end

  def after_sign_up_path_for(resource)
    customer_success_path
  end

  def after_inactive_sign_up_path_for(resource)
    customer_success_path
  end

end
