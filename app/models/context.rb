# Инициализируется всем, что известно про текущий запрос.
# Кто, откуда пришел, были заказы, залогинен в админку и т.п.
# Отвечает на вопросы, что ему можно, и как именно. А еще, наверное, сколько стоит.
# Просьба всю логику возможностей и настроек держать здесь, так проще тестировать.
# А о том, админ это, апи ли это и прочее - спрашивать только для логов и дебага.
# FIXME подумать о взаимосвязи с Ability. может быть, это одно и то же.
class Context
  include KeyValueInit

  # Текущий залогиненный в админку юзер
  attr_accessor :deck_user

  # Текущий партнер
  attr_accessor :partner

  # Запрос из API?
  attr_accessor :robot

  # Текущая конфигурация
  attr_accessor :config

  # @returns 'anonymous' для пустого партнера
  def partner_code
    partner.to_param
  end

  def config
    @config ||= Conf
  end

  def inspect
    attrs = {
      deck_user: deck_user,
      partner: partner.attributes.slice("id", "token", "enabled", "suggested_limit"),
      robot: robot,
      config: config
    }.map do |k, v|
      "#{k}: #{v.inspect}"
    end.join(', ')
    "<Context: #{attrs}>"
  end

  # @group Настройки и разрешения.

  # Сортировать рекомендации по цене.
  def pricer_sort?
    !robot
  end

  # Убирать неудобные, непродаваемые и т.п. рекомендации из выдачи.
  def pricer_filter?
    !deck_user
  end

  # Убирает временны'е ограничения при покупке билета
  def lax?
    !!deck_user
  end

  # FIXME Conf читать отсюда?
  # Разрешить запрос рекомендаций из GDS
  def pricer_enabled?
    partner ? partner.enabled? : true
  end

  # Рекомендованное количество рекомендаций в запросе к GDS
  def pricer_suggested_limit
    if robot
      partner.suggested_limit ||
      Partner.anonymous.suggested_limit ||
      Conf.amadeus.recommendations_lite
    else
      Conf.amadeus.recommendations_full
    end
  end

  # Искать рейсы в города в радиусе 200км от точек назначения.
  def pricer_search_around?
    !robot
  end

  def enabled_delayed_payment?
    return true if deck_user
    enabled_delivery? || enabled_cash?
  end

  def enabled_delivery?
    return true if deck_user
    !config.site.forbidden_delivery
  end

  def enabled_cash?
    return true if deck_user
    !config.site.forbidden_cash
  end
end
