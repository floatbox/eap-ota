class Profile::ConfirmationsController < Devise::ConfirmationsController

  layout "profile"

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    if successfully_sent?(resource)
      return render :json => {:success => true, :location => after_resending_confirmation_instructions_path_for(resource_name)}
    else
      return render :json => {:success => false, :errors => resource.errors.full_messages}
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])
    super if resource.nil? or resource.confirmed?
  end

  def confirm
    self.resource = resource_class.find_by_confirmation_token(params[resource_name][:confirmation_token])
    if resource.update_attributes(params[resource_name].except(:confirmation_token)) && resource.password_match?
      self.resource = resource_class.confirm_by_token(params[resource_name][:confirmation_token])
      set_flash_message :notice, :confirmed
      sign_in_and_redirect(resource_name, resource)
    else
      failure
    end
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    return render :json => {:success => true, :location => after_sign_in_path_for(resource)}
  end

  def failure
    return render :json => {:success => false, :errors => resource.errors.full_messages}
  end
  
end
