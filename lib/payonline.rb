# encoding: utf-8
require 'openssl'
require 'base64'
require 'httparty'

class Payonline
  # Примечание: формат возвращаемых платёжной системой данных регулируется параметром ContentType - text или xml. Text является форматом по умолчанию.
  # Однако тогда требуется дополнительный парсинг (в том числе парсинг csv для запроса list). Xml формат же имеет особенность: первая буква всех параметров переведена
  # в нижний регистр. Хотя ключи запросов не чувствительны к регистру, закодированные в md5 ключи чувствительны. Поэтому в методе валидации security key callback запроса
  # требуется capitalize для всех переданных ключей params. Кроме того, для единообразия capitalize будет применён ко всем ключам Response при инициализации кроме binCountry
  # (только он пишется с маленькой).

  # На данный момент реализован xml.

  # Все запросы, кроме auth (только Post), допускают использоване и Get, и Post. Сейчас все запросы используют Post.

  # Payonline в плане ошибок адекватно реагирует только на auth. В остальных случаях если что не так возвращает просто bad request 400 без пояснений. Это может быть
  # результатом как ошибочного синтаксиса (или отсутствия нужного параметра), так и, например, если указан несуществующий на самом деле transaction_id для операции void.
  # Так что дебаггинг в дальнейшем будет очень затруднён.
  # Метод search на данный момент ведёт на несуществующую страницу.
  # Для complete добиться что-либо кроме bad request не удаётся. Возможно, какие-то заморочки с idata.

  class Response
    def initialize(doc)
      @doc = doc && doc.inject({}) { |h, (k, v)| h[k == 'binCountry' ? k : k.capitalize] = v; h } || {}
    end

    def success?
      @doc["Result"] == "Ok"
    end
    
    # Будет возвращать также и код успешной операции, название оставлено err_code для совместимости с payture.
    def err_code
      @doc["ErrorCode"] || @doc["Code"]
    end

    def error?
      @doc["Success"] != "Ok"
    end

    def order_id
      @doc["OrderId"]
    end

    def transaction_id
      @doc["TransactionId"]
    end

    def amount
      @doc["Amount"].to_f
    end

    # new_amount отсутствует, т.к. void не поддерживает частичную разблокировку, а refund не возвращает оставшуюся часть суммы

    # PreAuthorized, Pending, Settled, Voided, Declined.
    def state
      @doc["Status"]
    end

  end

  def initialize(opts={})
    @host = opts[:host] || Conf.payonline.host
    @private_security_key = opts[:private_security_key] || Conf.payonline.private_security_key
    @merchant_id = opts[:merchant_id] || Conf.payonline.merchant_id
    @preauthorization = opts[:preauthorization] || Conf.payonline.preauthorization
  end

  # Инициация платежа в один шаг и в два шага выполняется в PayOnline одной и той же командой auth в зависимости от настроек платёжной системы, однако в этих подходах они
  # отличаются тем, передаётся ли параметр IData на стадии блокировки или же на стадии завершения платежа. Режим регулируется Conf.payonline.preauthorization.
  # В случае выбора неверного метода, он возвращает nil (при необходимости можно переделать на exception).
  # Возможна передача валюты ("RUB", "EUR", "USD"), по умолчанию выбираются рубли.
  def pay amount, card, opts={}, currency = "RUB"
    return nil if @preauthorization
    validate! opts, :order_id, :idata
    post = {}
    add_merchant_id(post)
    add_order_id(post, opts)
    add_money(post, amount)
    add_currency(post, currency)
    add_contacts_and_location(post, opts)
    add_creditcard(post, card)
    add_idata(post, opts)
    add_security_key(post)

    post_request "transaction/auth", post
  end

  # Блокировка средств на карте пользователя.
  def block amount, card, opts={}, currency = "RUB"
    return nil unless @preauthorization
    validate! opts, :order_id
    post = {}
    add_merchant_id(post)
    add_order_id(post, opts)
    add_money(post, amount)
    add_currency(post, currency)
    add_contacts_and_location(post, opts)
    add_creditcard(post, card)
    add_security_key(post)

    post_request "transaction/auth", post
  end

  # Списание средств при двухшаговом платеже в валюте изачального платежа. Допустимо частичное списание; по умолчанию списывается вся сумма.
  def charge amount = nil, opts={}
    return nil unless @preauthorization
    validate! opts, :transaction_id, :idata
    post = {}
    add_merchant_id(post)
    add_transaction_id(post, opts)
    add_money(post, amount)
    add_idata(post, opts)
    add_security_key(post)

    post_request 'transaction/complete', post
  end

  # Разблокировка средств (в том числе, если они ещё не успели списаться по платежу в один шаг).
  # Частичная разблокировка невозможна; параметр amount оставлен для совместимости с payture.
  def unblock amount, opts={}
    validate! opts, :transaction_id
    post = {}
    add_merchant_id(post)
    add_transaction_id(post, opts)
    add_security_key(post)

    post_request 'transaction/void', post
  end

  # Повторный платёж с указанием новой суммы. Предприятие должно отдельно подписаться на услугу повторных платежей.
  def rebill amount, opts={}, currency = "RUB"
    validate! opts, :rebill_anchor, :order_id
    post = {}
    add_merchant_id(post)
    add_rebill_anchor(post, opts)
    add_order_id(post, opts)
    add_money(post, amount)
    add_currency(post, currency)
    add_security_key(post)
    
    post_request 'transaction/rebill', post
  end

  # Возврат средств (полный или частичный) на карту пользователя в валюте платежа. Сумма должна быть указана даже в случае возврата всей суммы.
  def refund amount, opts={}
    validate! opts, :transaction_id
    post = {}
    add_merchant_id(post)
    add_transaction_id(post, opts)
    add_money(post, amount)
    add_security_key(post)

    post_request 'transaction/refund', post
  end

  # Уточнение текущего состояния платежа. Нужно указать либо order_id, либо transaction_id.
  def state opts={}
    post = {}
    add_merchant_id(post)
    add_order_id(post, opts) || add_transaction_id(post, opts)
    add_security_key(post)

    post_request 'search', post
  end

  # Возвращает список всех транзакций по критериям.
  def list opts={}
    validate! opts, :date_from, :date_till, :type, :status
    post = {}
    add_merchant_id(post)
    add_filters(post, opts)
    add_security_key(post)

    post_request 'transaction/list', post
  end

  # Проверка валидности security key callback запроса в контексте конкретного инстанса Payonline (у них может отличаться private security key).
  # Передаётся params, который при подтверждении данным методом должен скрамливаться Payonline::Response.new.
  def valid_security_key?(params)
    params["securityKey"] == md5(params.inject({}) { |h, (k, v)| h[k.capitalize] = v; h })
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  # По текущей документации адреса Payonline могут отличаться двумя элементами (для search дополнительно не указывается transaction), поэтому принимается строка с обеими
  # (например, "transaction/auth").
  def post_request action, args
    debug args.inspect
    response = HTTParty.post("https://#{@host}/payment/#{action}/", :body => args.merge(:ContentType => "xml"), :format => :xml)
    debug response.parsed_response.inspect
    if action == 'transaction/list'
      # list возвращает массив элементов; каждый из них преобразовывается в Response.
      response.parsed_response['list'] && response.parsed_response['list']['transaction'].map {|element| Response.new(element) } || []
    else
      Response.new( response.parsed_response.values.first )
    end
  end

  def add_order_id(post, opts)
    post[:OrderId] = opts[:order_id] if opts[:order_id]
  end

  def add_transaction_id(post, opts)
    post[:TransactionId] = opts[:transaction_id] if opts[:transaction_id]
  end

  def add_creditcard(post, creditcard)
    post[:CardNumber] = creditcard.number
    post[:CardExpDate] = Date.new(creditcard.year, creditcard.month).strftime("%m%y")
    post[:CardHolderName] = creditcard.name
    post[:CardCvv] = creditcard.verification_value
  end

  def add_merchant_id(post)
    post[:MerchantId] = @merchant_id
  end

  def add_money(post, money)
    # Cистема принимает суммы только с двумя десятичными знаками.
    post[:Amount] = "%.2f" % money if money
  end

  def add_currency(post, currency)
    post[:Currency] = currency
  end

  # Добавление ключа повторной транзакции.
  def add_rebill_anchor(post, opts)
    post[:RebillAnchor] = opts[:rebill_anchor] if opts[:rebill_anchor]
  end

  # Добавление длинной записи вида 0192224171UTVOKUF+++++++++++++++++++++029861572262150080610VKOSALINA+NATALIA++++++
  # На данный момент передаётся извне. Позже можно будет возложить формирование длинной записи на Payonline.
  def add_idata(post, opts)
    post[:IData] = opts[:idata] if opts[:idata]
  end

  # Набор локационно идентифицирующих пользователя параметров, обязательноcть которых устанавливается в платёжной системе индивидуального для каждого предприятия.
  def add_contacts_and_location(post, opts)
    [:ip, :email, :country, :city, :address, :zip, :state, :phone].each {|key| post[key.to_s.camelcase.to_sym] = opts[key] if opts[key]}
  end
  
  # Добавление фильтров, ограничивающих поиск операции list. Даты передаются в стандартном формате yyyy-MM-dd. Разница в датах должна быть не более 3 дней.
  # status (PreAuthorized, Pending, Settled, Voided, Declined) и type (Purchase, Refund) могут иметь по несколько элементов через запиятую.
  def add_filters(post, opts)
    [:date_from, :date_till, :type, :status].each {|key| post[key.to_s.camelcase.to_sym] = opts[key].to_s if opts[key]}
  end

  def add_security_key(post)
    post[:SecurityKey] = md5(post.merge(:PrivateSecurityKey => @private_security_key))
  end

  # Кодирование необходимых данных в md5 для security key; может использоваться в том числе для проверки валидности ключа в callback запросе.
  def md5(post)
    keys = [:MerchantId, :TransactionId, :RebillAnchor, :OrderId, :Amount, :Currency, :DateFrom, :DateTill, :Type, :Status, :IData, :PrivateSecurityKey]
    Digest::MD5.hexdigest( keys.find_all{|k| post[k]}.collect {|k| "#{k}=#{post[k]}" }.join('&') )
  end

  def debug message
    Rails.logger.info "Payonline: #{message}"
  end

end