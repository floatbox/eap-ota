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
  
  POST_PARAMS = {
    :MERCHANT              => 'EVITERRA',                #your merchant code in PAYU system 
    :ORDER_REF             => 'EXT_' + Random.rand(1000).to_s,   #your internal reference number
    :REFNOEXT              => 'EXT_' + Random.rand(1000).to_s,   #your internal reference number
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
    # FIXME откуда это? в php примере его нет:
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

  module Hashing
    def hash_string(key, hash, order=hash.keys)
      OpenSSL::HMAC.hexdigest('md5', key, serialize_array(hash.values_at(*order)))
    end

    def serialize_array(array)
      array.flatten.compact.map { |val| "#{val.length}#{val}" }.join
    end
  end

  include Hashing

  class PaymentResponse

    def initialize(parsed_response)
      if parsed_response.has_key? 'EPAYMENT'
        @doc = parsed_response['EPAYMENT']
      else
        @doc = parsed_response
      end
    end

    def success?
      @doc['STATUS'] == 'SUCCESS' && !threeds?
    end

    def err_code
    end

    def error?
      !success? && !threeds?
    end

    def their_ref
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
      @their_ref, @code, @message, @date_str, @hash = m[1].split('|')
    end

    # FIXME хз, верно ли. нарыть доку
    def success?
      @code == '1'
    end

    def their_ref
      @their_ref
    end

  end

  class ChargeResponse
    def initialize(piped_string)
      raise ArgumentError, "unexpected input: #{piped_string}" unless
        m = piped_string.match(/<EPAYMENT>(.*)<\/EPAYMENT>/)
      @their_ref, @code, @message, @date_str, @hash = m[1].split('|')
    end

    # FIXME хз, верно ли. нарыть доку
    def success?
      @code == '1'
    end

    def their_ref
      @their_ref
    end

  end

  class StateResponse
    def initialize(parsed_response)
      if parsed_response.has_key? 'Order'
        @doc = parsed_response['Order']
      end
    end

    # Order status can be:
    # COMPLETE
    # PAYMENT_AUTHORIZED
    # REFUND
    # REVERSED
    # IN_PROGRESS (waiting)
    # WAITING_PAYMENT
    def success?
      @doc["ORDER_STATUS"] == 'PAYMENT_AUTHORIZED'
    end

    def error?
      !success?
    end

    def complete?
      @doc["ORDER_STATUS"] == 'COMPLETE'
    end

    def status
      @doc["ORDER_STATUS"]
    end

    def their_ref
      @doc['REFNO']
    end

    def our_ref
      @doc['REFNOEXT']
    end

  end

  def initialize(opts={})
    @merchant = opts[:merchant] || Conf.payu.merchant
    @host = opts[:host] || Conf.payu.host
    @seller_key = opts[:seller_key] || Conf.payu.seller_key
  end

  # блокировка средств на карте пользователя
  def block amount, card, opts={}
    post = POST_PARAMS.dup
    add_our_ref(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
#    add_custom_fields(post, opts)
    post[:ORDER_DATE] = time_now_string
    post.slice!(*PAY_PARAMS_ORDER)
    post[:ORDER_HASH] = hash_string(@seller_key, post)

    parsed_response = post_alu(post)
    PaymentResponse.new( parsed_response )
  end

  # внутренний метод для собственно HTTP вызова сервиса блокировки/платежа
  # облегчает тестирование
  def post_alu(post)
    logger.debug post
    response = HTTParty.post("https://#{@host}/order/alu.php", :body => post)
    logger.debug response.inspect
    response.parsed_response
  end

  CHARGE_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_AMOUNT, :ORDER_CURRENCY, :IDN_DATE
  ]

  def charge amount, opts={}
    post = {}
    add_their_ref(post, opts)
    add_merchant(post)
    add_money(post, amount)
    post[:IDN_DATE] = time_now_string
    post.slice!(*CHARGE_PARAMS_ORDER)
    post[:ORDER_HASH] = hash_string(@seller_key, post)

    response = HTTParty.post("https://#{@host}/order/idn.php", :body => post)
    logger.debug response.inspect
    ChargeResponse.new( response.parsed_response )
  end

  REFUND_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_AMOUNT, :ORDER_CURRENCY, :IRN_DATE
  ]

  # разблокировка средств.
  # частичная блокировка не принимается
  def unblock amount, opts={}
    post = {}
    add_their_ref(post, opts)
    add_merchant(post)
    add_money(post, amount)

    post[:IRN_DATE] = time_now_string
    post.slice!(*REFUND_PARAMS_ORDER)
    post[:ORDER_HASH] = hash_string(@seller_key, post)

    response = HTTParty.post("https://#{@host}/order/irn.php", :body => post)
    logger.debug response.inspect
    UnblockResponse.new( response.parsed_response )
  end

  # возврат средств (полный или частичный) на карту пользователя
  # в PayU делается той же командой
  def refund amount, opts={}
    unblock amount, opts
  end

  STATE_PARAMS_ORDER = [
    :MERCHANT, :REFNOEXT
  ]

  # уточнение текущего состояния платежа
  def status opts={}
    post = {}
    add_our_ref(post, opts)
    add_merchant(post)

    post.slice!(*STATE_PARAMS_ORDER)
    post[:HASH] = hash_string(@seller_key, post)

    response = HTTParty.get("https://#{@host}/order/ios.php", :query => post)
    logger.debug response.inspect
    StateResponse.new( response.parsed_response )
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  def add_our_ref(post, options={})
    post[:ORDER_REF] = options[:our_ref]
    post[:REFNOEXT] = options[:our_ref]
    post[:BACK_REF] = 'http://localhost:3000/'
  end

  def add_their_ref(post, options={})
    post[:ORDER_REF] = options[:their_ref]
  end

  def add_creditcard(post, creditcard)
    post[:CC_NUMBER] = creditcard.number
    post[:CC_TYPE] =
      case creditcard.type
      when 'master'
        'MasterCard'
      when 'visa', 'bogus'
        'VISA'
      else
        raise ArgumentError, "unsupported creditcard type: #{creditcard.type.inspect}"
      end
    post[:EXP_MONTH] = "%02d" % creditcard.month
    post[:EXP_YEAR] = "%04d" % creditcard.year
    post[:CC_OWNER] = creditcard.name
    post[:CC_CVV] = creditcard.verification_value
  end

  def add_merchant(post)
    post[:MERCHANT] = @merchant
  end

  def add_money(post, money)
    post[:ORDER_PRICE] = [money.to_s]
    post[:ORDER_AMOUNT] = money.to_s
    post[:PRICES_CURRENCY] = 'RUB'
    post[:ORDER_CURRENCY] = 'RUB'
  end

  def time_now_string
    Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
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

  # for testing purposes
  def self.test_card(opts = {})
    CreditCard.new(
      {:number => '4111111111111111', :verification_value => '123', :year => 2013, :month => 12, :name => 'card one'}.merge(opts)
    ).tap(&:valid?)
  end

end
