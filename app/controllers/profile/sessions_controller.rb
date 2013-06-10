class Profile::SessionsController < Devise::SessionsController
  
  layout "profile"
  
  def create
    hash ||= params[resource_name] || {}
    resource = resource_class.find_by_email(hash[:email])
    if resource.nil?    ## кастомера нет в таблице
      not_found
    elsif resource.not_registred?   ## кастомер есть но не создавал ЛК
      not_found
    elsif resource.pending_confirmation?    ## кастомер зарегистрировался но не конфермил ЛК по ссылке
      not_confirmed
    elsif
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
      sign_in_and_redirect(resource_name, resource)
    end
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    return render :json => {:success => true, :location => after_sign_in_path_for(resource)}
  end

  def not_found
    return render :json => {:success => false, :errors => ["not_found"]}
  end

  def not_confirmed
    return render :json => {:success => false, :errors => ["not_confirmed"]}
  end

  def failure
    return render :json => {:success => false, :errors => ["failed"]}
  end

end
