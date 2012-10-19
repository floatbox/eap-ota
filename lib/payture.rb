# encoding: utf-8
require 'openssl'
require 'base64'
require 'httparty'

class Payture

  # комиссионные за транзакцию
  def self.commission
    @commission ||= Commission::Formula.new(Conf.payture.commission)
  end

  class Response
    def initialize(doc)
      @doc = doc
    end

    def success?
      @doc["Success"].to_s.downcase == "true"
    end

    def err_code
      @doc["ErrCode"]
    end

    # не !success? потому что может быть и "3DS"
    def error?
      @doc["Success"].to_s.downcase == "false"
    end

    def our_ref
      @doc["OrderId"]
    end

    def amount
      @doc["Amount"].to_f / 100
    end

    def new_amount
      @doc["NewAmount"].to_f / 100
    end

    # 3-D Secure

    def threeds?
      @doc["Success"].to_s.downcase == "3ds"
    end

    def threeds_url
      @doc["ACSUrl"]
    end

    # FIXME найти способ прокидывать сюда конфирмационный урл
    def threeds_return_url
      'https://eviterra.com/confirm_3ds'
    end

    def threeds_params
      {
        'PaReq' => pa_req,
        'MD' => threeds_key,
        'TermUrl' => threeds_return_url
      }
    end

    def pa_req
      @doc["PaReq"]
    end

    def threeds_key
      @doc["ThreeDSKey"]
    end

    # GetState
    # 'PreAuthorized3DS', 'Voided', 'Rejected', какие еще?
    def status
      @doc["State"]
    end

    # "11/12/2010 9:24:07 AM"
    def last_change
      @doc["LastChange"]
    end
  end

  def initialize(opts={})
    @key = opts[:key] || Conf.payture.key
    @host = opts[:host] || Conf.payture.host
    @ssl = opts[:ssl]
    @ssl = Conf.payture.ssl if @ssl.nil?
    @public = OpenSSL::PKey::RSA.new(opts[:pem] || Conf.payture.pem)
  end

  def pay amount, card, opts={}
    post = {}
    add_order(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    encrypt_payinfo(post)

    post_request 'Pay', post
  end

  # блокировка средств на карте пользователя
  def block amount, card, opts={}
    post = {}
    add_order(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    add_custom_fields(post, opts[:custom_fields])
    encrypt_payinfo(post)

    post_request 'Block', post
  end

  def block_3ds opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    add_3ds_info(post, opts)

    post_request 'Block3DS', post
  end

  def charge opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)

    post_request 'Charge', post
  end

  # разблокировка средств.
  # частичная блокировка не принимается
  def unblock amount, opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    add_money(post, amount)

    post_request 'Unblock', post
  end

  # возврат средств (полный или частичный) на карту пользователя
  def refund amount, opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    add_money(post, amount)

    post_request 'Refund', post
  end

  # уточнение текущего состояния платежа
  # {"Comment"=>"", "Tag"=>"", "LastChange"=>"11/12/2010 9:24:07 AM", "State"=>"Charged"}
  # "State"=>"Authorized", "Voided", "Charged"
  def status opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)

    post_request 'GetState', post
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  def post_request action, args
    response = HTTParty.post("#{@ssl ? 'https' : 'http'}://#{@host}/api/#{action}/", :body => args, :format => :xml)
    debug response.parsed_response.inspect
    Response.new( response.parsed_response.values.first )
  end

  # copied back from active_merchant alfa_bank_gateway
  def add_order(post, options={})
    validate! options, :our_ref
    post[:OrderId] = options[:our_ref]
  end

  def add_creditcard(post, creditcard)
    post[:PAN] = creditcard.number
    post[:EMonth] = "%02d" % creditcard.month
    post[:EYear] = "%02d" % (creditcard.year - 2000)
    post[:CardHolder] = creditcard.name
    post[:SecureCode] = creditcard.verification_value
  end

  def add_merchant(post)
    post[:Key] = @key
  end

  def add_3ds_info(post, opts)
    post[:PaRes] = opts[:pa_res]
  end

  def add_money(post, money)
    # система принимает суммы в копейках
    post[:Amount] = (money.to_f * 100).round.to_i.to_s
  end

  def encrypt_payinfo(post)
    keys = [:PAN, :EMonth, :EYear, :CardHolder, :SecureCode, :OrderId, :Amount]
    pay_info_string = keys.find_all{|k| post[k]}.collect {|k| "#{k}=#{post[k]}" }.join(';')
    post[:PayInfo] = Base64::encode64( encrypt(pay_info_string) ).rstrip
    [:PAN, :EMonth, :EYear, :CardHolder, :SecureCode].each {|key| post.delete(key) }
  end

  def add_custom_fields(post, custom_fields)
    return unless custom_fields
    res = {
      :IP => custom_fields.ip,
      :FirstName => custom_fields.first_name,
      :LastName => custom_fields.last_name,
      :Phone => custom_fields.phone,
      :Email => custom_fields.email,
      :Date => custom_fields.date.try(:strftime, '%Y.%m.%d'),
      :Segments => custom_fields.segments,
      :Description => custom_fields.description
    }
    if custom_fields.points
      res[:From] = custom_fields.points.first
      1.upto(custom_fields.segments) do |i|
        res[:"To#{i}"] = custom_fields.points[i]
      end
    end
    post[:CustomFields] = res.delete_if {|k, v| !v }.collect {|k, v| "#{k}=#{v}"}.join(';')
  end

  def encrypt(string)
    @public.public_encrypt(string)
  end

  def debug message
    Rails.logger.info "Payture: #{message}"
  end

  # for testing purposes
  def self.test_card(opts = {})
    CreditCard.new(
      {:number => '4111111111111112', :verification_value => '123', :year => 2012, :month => 12, :name => 'card one'}.merge(opts)
    )
  end

  def self.test_card2(opts = {})
    CreditCard.new(
      {:number => '5222230546300090', :verification_value => '123', :year => 2012, :month => 12, :name => 'card two'}.merge(opts)
    )
  end

  ERRORS_EXPLAINED = {
    'NONE'                      => 'Операция выполнена без ошибок',
    'ACCESS_DENIED'             => 'Доступ с текущего IP или по указанным параметрам запрещен',
    'AMOUNT_ERROR'              => 'Неверно указана сумма транзакции',
    'AMOUNT_EXCEED_BALANCE'     => 'Сумма транзакции превышает доступный остаток средств на карте',
    'API_NOT_ALLOWED'           => 'Данный API не разрешен к использованию',
    'DUPLICATE_ORDER_ID'        => 'Номер заказа уже использовался ранее',
    'ISSUER_CARD_FAIL'          => 'Банк эмитент запретил интернет транзакции по карте',
    'ISSUER_FAIL'               => 'Владелец карты пытается выполнить транзакцию, которая для него не разрешена эмитентом, либо внутренняя ошибка эмитента',
    'ISSUER_LIMIT_FAIL'         => 'Предпринята попытка, превышающая ограничения эмитента на сумму или количество операций в определенный промежуток времени',
    'FRAUD_ERROR'               => 'Транзакция отклонена фрод-мониторингом',
    'ILLEGAL_ORDER_STATE'       => 'Попытка выполнения недопустимой операции для текущего состояния платежа',
    'MERCHANT_RESTRICTION'      => 'Превышены ограничения Продавца',
    'ORDER_NOT_FOUND'           => 'Платеж с указанным OrderId не найден',
    'ORDER_TIME_OUT'            => 'Время платежа истекло',
    'PROCESSING_ERROR'          => 'Отказ процессинга в выполнении операции',
    'REAUTH_NOT_ALOWED'         => 'Заблокированная сумма не может быть изменена',
    'REFUND_NOT_ALOWED'         => 'Возврат не может быть выполнен',
    'REFUSAL_BY_GATE'           => 'Отказ шлюза в выполнении операции',
    'THREE_DS_FAIL'             => 'Невозможно выполнить 3DS транзакцию',
    'WRONG_CARD_INFO'           => 'Введены неправильные параметры карты',
    'WRONG_CARD_PAN'            => 'Неверный номер карты',
    'WRONG_CARDHOLDER_NAME'     => 'Недопустимое имя держателя карты',
    'WRONG_PARAMS'              => 'Неверный набор или формат параметров',
    'WRONG_PAY_INFO'            => 'Некорректный параметр PayInfo (неправильно сформирован или нарушена криптограмма)'
  }

end
