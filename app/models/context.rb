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

  # Запрос из API?
  attr_accessor :robot

  # Partner, ассоциированный с текущим клиентом
  def partner
    @partner || Partner.anonymous
  end

  # @param Код партнера или уже готовый партнер
  def partner=(partner_or_code)
    case partner_or_code
    when Partner
      @partner = partner_or_code
    else
      # Partner[] для несуществующих кодов возвращает Partner.anonymous
      @partner = Partner[partner_or_code]
    end
  end

  # @returns 'anonymous' для пустого партнера
  def partner_code
    partner.to_param
  end

  # @group Настройки и разрешения.

  # Сортировать рекомендации по цене.
  def pricer_sort?
    ! robot
  end

  # Убирать неудобные, непродаваемые и т.п. рекомендации из выдачи.
  def pricer_filter?
    ! deck_user
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
    ! robot
  end

end
