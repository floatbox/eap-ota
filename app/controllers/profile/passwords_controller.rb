class Profile::PasswordsController < Devise::PasswordsController

  layout "profile"

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      return render :json => {:success => true, :location => after_sending_reset_password_instructions_path_for(resource_name)}
    else
      return render :json => {:success => false, :errors => ["not_found"]}
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      return render :json => {:success => true, :location => after_resetting_password_path_for(resource)}
    else
      return render :json => {:success => false, :errors => resource.errors.full_messages}
    end
  end

end
