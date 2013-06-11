class Profile::PasswordsController < Devise::PasswordsController
  
  layout "profile"

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      success
    else
      failure
    end
  end

  def success
    return render :json => {:success => true, :location => after_sending_reset_password_instructions_path_for(resource_name)}
  end

  def failure
    return render :json => {:success => false, :errors => ["not_found"]}
  end

end
