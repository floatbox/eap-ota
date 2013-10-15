class Profile::RegistrationsController < Devise::RegistrationsController

  layout "profile"

  def create
    hash ||= params[resource_name] || {}
    exist_resource = resource_class.find_by_email(hash[:email])
    if exist_resource.nil? ## такого кастомера нет в базе

      build_resource
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          success
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          success
        end
      else
        clean_up_passwords resource
        return render :json => {:success => false, :errors => ["save_error"]}
      end

    elsif exist_resource.not_registred?   ## кастомер есть но не создавал ЛК
      exist_resource.send_confirmation_instructions
      success
    elsif exist_resource.pending_confirmation?    ## кастомер зарегистрировался но не конфермил ЛК по ссылке
      not_confirmed
    else
      exist_failure
    end
  end

  def success
    return render :json => {:success => true, :location => after_inactive_sign_up_path_for(resource)}
  end

  def not_confirmed
    return render :json => {:success => false, :errors => ["not_confirmed"]}
  end

  def exist_failure
    return render :json => {:success => false, :errors => ["exist"]}
  end

end
