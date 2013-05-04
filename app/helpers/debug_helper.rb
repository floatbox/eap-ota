module DebugHelper
  def debug_service_env(service)
    conf = Conf.send(service)
    # убрал, для большинства сервисов enabled сейчас не используется
    #status = conf.enabled ? conf.env : 'disabled'
    status = conf.env
    if status != Rails.env
      "<span style='color:red'>#{status}</span>".html_safe
    else
      status
    end
  end
end
