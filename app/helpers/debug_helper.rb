module DebugHelper
  def debug_service_env(service)
    conf = Conf.send(service)
    status = conf.enabled ? conf.env : 'disabled'
    if status != Rails.env
      "<span style='color:red'>#{status}</span>".html_safe
    else
      status
    end
  end
end
