# encoding: utf-8
require 'openssl'
require 'httparty'
require 'active_support/all'

class Payu

  cattr_accessor :logger do
    Rails.logger
  end

  PAY_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_DATE, :ORDER_PNAME, :ORDER_PCODE, :ORDER_PINFO, :ORDER_PRICE, :ORDER_QTY,
    :ORDER_VAT, :ORDER_VER, :ORDER_SHIPPING, :PRICES_CURRENCY, :DISCOUNT,
    :DESTINATION_CITY, :DESTINATION_STATE, :DESTINATION_COUNTRY, :PAY_METHOD,
    :CC_NUMBER, :EXP_MONTH, :EXP_YEAR, :CC_TYPE, :CC_CVV, :CC_OWNER, :ORDER_PGROUP,

    :BACK_REF, :REFNO, :ALIAS, :CLIENT_IP,

    :BILL_LNAME, :BILL_FNAME, :BILL_CISERIAL, :BILL_CINUMBER, :BILL_CIISSUER, :BILL_CNP, :BILL_COMPANY, :BILL_FISCALCODE,
    :BILL_REGNUMBER, :BILL_BANK, :BILL_BANKACCOUNT, :BILL_EMAIL, :BILL_PHONE, :BILL_FAX, :BILL_ADDRESS, :BILL_ADDRESS2,
    :BILL_ZIPCODE, :BILL_CITY, :BILL_STATE, :BILL_COUNTRYCODE,

    :DELIVERY_LNAME, :DELIVERY_FNAME, :DELIVERY_COMPANY, :DELIVERY_PHONE, :DELIVERY_ADDRESS, :DELIVERY_ADDRESS2,
    :DELIVERY_ZIPCODE, :DELIVERY_CITY, :DELIVERY_STATE, :DELIVERY_COUNTRYCODE, :DELIVERY_EMAIL
  ]
  
  REFUND_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_AMOUNT, :ORDER_CURRENCY, :IRN_DATE
  ]

  CHARGE_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_AMOUNT, :ORDER_CURRENCY, :IDN_DATE
  ]

  POST_PARAMS = {
    :MERCHANT              => 'EVITERRA',                #your merchant code in PAYU system 
    :ORDER_REF             => 'EXT_' + Random.rand(1000).to_s,   #your internal reference number
    :ORDER_DATE            => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
    :IRN_DATE              => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
    :IDN_DATE              => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
    :ORDER_PNAME           => ['1 x Ticket'],            #product name
    :ORDER_PCODE           => ['TCK1'],                  #product code
    :ORDER_PINFO           => ["{'departuredate':20120914, 'locationnumber':2, 'locationcode1':'BUH', 'locationcode2':'IBZ','passengername':'Fname Lname','reservationcode':'abcdef123456'}"],
    :ORDER_PRICE           => ['1'],                     #order price
    :ORDER_AMOUNT          => '1',                       #order amount
    :ORDER_VAT             => ['0'],                     #order vat
    :ORDER_QTY             => ['1'],                     #products quantity
    :PRICES_CURRENCY       => 'RUB',                     #currency
    :ORDER_CURRENCY        => 'RUB',                     #currency
    :PAY_METHOD            => 'CCVISAMC',                #payment method used. You should always leave it CCVISAMC
    :CC_NUMBER             => '4111111111111111',        #cardholder number
    :CC_OWNER              => 'Test Eviterra',           #cardholder full name
    :CC_TYPE               => 'VISA',                    #card type
    :CC_CVV                => '123',                     #card cvc/cvv
    :EXP_MONTH             => '11',                      #card expiry month
    :EXP_YEAR              => '2014',                    #card expiry yeaer

    :BILL_LNAME            => 'Eviterra',                #billing customer last name
    :BILL_FNAME            => 'Test',                    #billing customer first name
    :BILL_ADDRESS          => 'Address Eviterra',        #billing customer address
    :BILL_CITY             => 'City',                    #billing customer city
    :BILL_STATE            => 'State',                   #billing customer State
    :BILL_ZIPCODE          => '123',                     #billing customer Zip
    :BILL_EMAIL            => 'testpayu@eviterra.com',   #billing customer email
    :BILL_PHONE            => '1234567890',              #billing customer phone
    :BILL_COUNTRYCODE      => 'RU',                      #billing customer 2 letter country code
    :CLIENT_IP             => '127.0.0.1',               #client IP used for antifraud purposes

    :DELIVERY_LNAME        => 'Eviterra',                #delivery last name
    :DELIVERY_FNAME        => 'Test',                    #delivery first name 
    :DELIVERY_ADDRESS      => 'Address Eviterra',        #delivery address
    :DELIVERY_CITY         => 'City',                    #delivery city
    :DELIVERY_STATE        => 'State',                   #delivery state
    :DELIVERY_ZIPCODE      => '123',                     #delivery Zip
    :DELIVERY_PHONE        => '1234567890',              #delivery phone
    :DELIVERY_COUNTRYCODE  => 'RU',                      #delivery 2 letter country code
  }

  class PaymentResponse

    def initialize(parsed_response)
      @doc = parsed_response['EPAYMENT']
    end

    def success?
      @doc['STATUS'] == 'SUCCESS' && !threeds?
    end

    def err_code
    end

    def error?
      !success? && !threeds?
    end

    def ref
      @doc['REFNO']
    end

    # 3-D Secure

    def threeds?
      @doc['RETURN_CODE'].to_s == "3DS_ENROLLED"
    end

    def acs_url
    end

    def pa_req
    end

    def threeds_key
    end

    def threeds_url
      @doc["URL_3DS"]
    end

    # GetState
    # 'PreAuthorized3DS', 'Voided', 'Rejected', какие еще?
    def state
    end

    # "11/12/2010 9:24:07 AM"
    def last_change
    end
  end

  class UnblockResponse
    def initialize(piped_string)
      raise ArgumentError, "unexpected input: #{piped_string}" unless
        m = piped_string.match(/<EPAYMENT>(.*)<\/EPAYMENT>/)
      @ref, @code, @message, @date_str, _ = m[1].split('|')
    end

    # FIXME хз, верно ли. нарыть доку
    def success?
      @code == '1'
    end

    def ref
      @ref
    end

  end

  class ChargeResponse
    def initialize(piped_string)
      raise ArgumentError, "unexpected input: #{piped_string}" unless
        m = piped_string.match(/<EPAYMENT>(.*)<\/EPAYMENT>/)
      @ref, @code, @message, @date_str, _ = m[1].split('|')
    end

    # FIXME хз, верно ли. нарыть доку
    def success?
      @code == '1'
    end

    def ref
      @ref
    end

  end

  def initialize(opts={})
    @merchant = opts[:merchant] || Conf.payu.merchant
    @host = opts[:host] || Conf.payu.host
    @seller_key = opts[:seller_key] || Conf.payu.seller_key
  end

  def pay amount, card, opts={}
  end

  # блокировка средств на карте пользователя
  def block amount, card, opts={}
    post = POST_PARAMS.dup
    add_order(post, opts)
#    add_money(post, amount)
    add_merchant(post)
#    add_creditcard(post, card)
    add_testcard_as_hash(post, card) if card
#    add_custom_fields(post, opts)
    encrypt_postinfo(post, PAY_PARAMS_ORDER)

    response = HTTParty.post("https://#{@host}/order/alu.php", :body => post)
    logger.debug response.inspect
    PaymentResponse.new( response.parsed_response )
  end

  def block_3ds opts={}
  end

  def charge opts={}
    post = POST_PARAMS.dup
    add_order(post, opts)
    #add_merchant(post)
    #add_money(post, amount)
    encrypt_postinfo(post, CHARGE_PARAMS_ORDER)

    response = HTTParty.post("https://#{@host}/order/idn.php", :body => post)
    logger.debug response.inspect
    ChargeResponse.new( response.parsed_response )
  end

  # разблокировка средств.
  # частичная блокировка не принимается
  def unblock opts={}
    post = POST_PARAMS.dup
    add_order(post, opts)
    #add_merchant(post)
    #add_money(post, amount)
    encrypt_postinfo(post, REFUND_PARAMS_ORDER)

    response = HTTParty.post("https://#{@host}/order/irn.php", :body => post)
    logger.debug response.inspect
    UnblockResponse.new( response.parsed_response )
  end

  # возврат средств (полный или частичный) на карту пользователя
  def refund amount, opts={}
  end

  # уточнение текущего состояния платежа
  # {"Comment"=>"", "Tag"=>"", "LastChange"=>"11/12/2010 9:24:07 AM", "State"=>"Charged"}
  # "State"=>"Authorized", "Voided", "Charged"
  def state opts={}
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  # copied back from active_merchant alfa_bank_gateway
  def add_order(post, options={})
    validate! options, :order_id
    post[:ORDER_REF] = options[:order_id]
  end

  def add_creditcard(post, creditcard)
    post[:CC_NUMBER] = creditcard.number
    post[:CC_TYPE] = creditcard.type
    post[:EXP_MONTH] = "%02d" % creditcard.month
    post[:EXP_YEAR] = "%02d" % (creditcard.year - 2000)
    post[:CC_OWNER] = creditcard.name
    post[:CC_CVV] = creditcard.verification_value
  end

  def add_testcard_as_hash(post, options={})
    post[:CC_NUMBER] = options[:number]
    post[:CC_TYPE] = options[:type]
    post[:EXP_MONTH] = options[:month]
    post[:EXP_YEAR] = options[:year]
    post[:CC_OWNER] = options[:name]
    post[:CC_CVV] = options[:verification_value]
  end

  def add_merchant(post)
    post[:MERCHANT] = @merchant
  end

  def add_3ds_info(post, opts)
    post[:PaRes] = opts[:pa_res]
  end

  def add_money(post, money)
    post[:Amount] = (money.to_f * 100).round.to_i.to_s
  end

  def update_date(post)
    post[:ORDER_DATE] = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    post[:IRN_DATE] = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    post[:IDN_DATE] = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
  end

  def encrypt_postinfo(post, params_order)
    update_date(post)
    post.select! {|key,value| params_order.include? key}
    post[:ORDER_HASH] = OpenSSL::HMAC.hexdigest('md5', @seller_key, get_hash(post, params_order))
  end

  def add_custom_fields(post, opts)
    custom_fields = opts[:custom_fields] or return
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

  def get_hash(post, params_order_array)
    hashString = ''
    params_order_array.each do |name|
      value = post[name]
      if value
        if value.is_a? Array 
          hashString += serialize_array value
        else
          hashString += value.length.to_s + value
        end
      end
    end
    hashString
  end
  
  def serialize_array myarray
    retvalue = "";

    myarray.each do |val|
      if val.is_a? Array
        retvalue += serialize_array(val)
      else
        retvalue += val.length.to_s + val.to_s
      end
    end

    retvalue
  end

  # for testing purposes
  def self.test_card(opts = {})
    CreditCard.new(
      {:number => '4111111111111111', :type => 'VISA', :verification_value => '123', :year => 2013, :month => 12, :name => 'card one'}.merge(opts)
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
