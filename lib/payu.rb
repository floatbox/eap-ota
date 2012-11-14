# encoding: utf-8
require 'openssl'
require 'httparty'
require 'active_support/all'

class Payu

  include ActiveSupport::Benchmarkable

  cattr_accessor :logger do
    Rails.logger
  end

  module Hashing
    def hash_string(key, hash, order=hash.keys)
      OpenSSL::HMAC.hexdigest('md5', key, serialize_array(hash.values_at(*order)))
    end

    def serialize_array(array)
      array.flatten.compact.map { |val| "#{val.length}#{val}" }.join
    end
  end

  class PaymentResponse

    include Hashing

    def initialize(parsed_response, seller_key=nil)
      @seller_key = seller_key
      if parsed_response.has_key? 'EPAYMENT'
        @doc = parsed_response['EPAYMENT']
      else
        @doc = parsed_response
      end
    end

    def success?
      @doc['STATUS'] == 'SUCCESS' && !threeds?
    end

    def error?
      !success? && !threeds?
    end

    def err_code
      error? && @doc['RETURN_CODE']
    end

    def err_message
      error? && @doc['RETURN_MESSAGE']
    end

    def their_ref
      @doc['REFNO']
    end

    # 3-D Secure

    def threeds?
      @doc['RETURN_CODE'].to_s == "3DS_ENROLLED"
    end

    def threeds_url
      @doc["URL_3DS"]
    end

    # не требуются
    def threeds_params
      {}
    end

    def hash
      @doc["HASH"]
    end

   def signed?
     hash == computed_hash
   end

   def computed_hash
     raise unless @seller_key
     hash_string(
       @seller_key, @doc,
       %W[ REFNO ALIAS STATUS RETURN_CODE RETURN_MESSAGE DATE ]
     )
   end

   def params
     @doc.values_at(*%W[ REFNO ALIAS STATUS RETURN_CODE RETURN_MESSAGE DATE ]).join('/')
   end

  end

  class ConfirmationResponse
    def initialize(piped_string)
      raise ArgumentError, "unexpected input: #{piped_string}" unless
        m = piped_string.match(/<EPAYMENT>(.*)<\/EPAYMENT>/)
      @their_ref, @code, @message, @date_str, @hash = m[1].split('|')
    end

    # FIXME хз, верно ли. нарыть доку
    def success?
      @code == '1'
    end

    def error?
      !success?
    end

    def err_code
      return if success?
      @code
    end

    def err_message
      return if success?
      @message
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

    def err_code; nil; end

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

  include Hashing

  def initialize(opts={})
    @merchant = opts[:merchant] || Conf.payu.merchant
    @host = opts[:host] || Conf.payu.host
    @seller_key = opts[:seller_key] || Conf.payu.seller_key
  end

  BLOCK_PARAMS_ORDER = [
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

  # блокировка средств на карте пользователя
  def block amount, card, opts={}
    validate! opts, :our_ref, :custom_fields
    post = {
      ORDER_REF: opts[:our_ref],
      ORDER_DATE: time_now_string,
      BACK_REF: threeds_return_url
    }
    alu_add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    add_custom_fields(post, opts[:custom_fields])
    post.slice!(*BLOCK_PARAMS_ORDER)
    post[:ORDER_HASH] = hash_string(@seller_key, post)

    parsed_response = alu_post(post)
    PaymentResponse.new( parsed_response, @seller_key )
  end

  # внутренний метод для собственно HTTP вызова сервиса блокировки/платежа
  # облегчает тестирование
  def alu_post(post)
    logger.info 'Payu: ' + post.inspect
    response =
      benchmark 'Payu ALU' do
        HTTParty.post("https://#{@host}/order/alu.php", :body => post)
      end
    logger.info 'Payu: ' + response.parsed_response.inspect
    response.parsed_response
  end

  # FIXME найти более удачный способ прокидывать сюда конфирмационный урл
  def threeds_return_url
    "#{Conf.site.host}/confirm_3ds"
  end

  # просто парсит 3дс ответ от гейтвея
  def parse_3ds params
    PaymentResponse.new( params, @seller_key )
  end

  CHARGE_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_AMOUNT, :ORDER_CURRENCY, :IDN_DATE
  ]

  def charge amount, opts={}
    validate! opts, :their_ref
    post = {
      ORDER_REF: opts[:their_ref],
      IDN_DATE: time_now_string
    }
    add_merchant(post)
    idn_add_money(post, amount)
    post.slice!(*CHARGE_PARAMS_ORDER)
    post[:ORDER_HASH] = hash_string(@seller_key, post)

    logger.info 'Payu: ' + post.inspect
    response =
      benchmark 'Payu IDN' do
        HTTParty.post("https://#{@host}/order/idn.php", :body => post)
      end

    logger.info 'Payu: ' + response.parsed_response.inspect
    ConfirmationResponse.new( response.parsed_response )
  end

  UNBLOCK_PARAMS_ORDER = [
    :MERCHANT, :ORDER_REF, :ORDER_AMOUNT, :ORDER_CURRENCY, :IRN_DATE
  ]

  # разблокировка средств.
  # частичная блокировка не принимается
  def unblock amount, opts={}
    validate! opts, :their_ref
    post = {}
    post[:ORDER_REF] = opts[:their_ref]
    add_merchant(post)
    idn_add_money(post, amount)

    post[:IRN_DATE] = time_now_string
    post.slice!(*UNBLOCK_PARAMS_ORDER)
    post[:ORDER_HASH] = hash_string(@seller_key, post)

    logger.info 'Payu: ' + post.inspect
    response =
      benchmark 'Payu IRN' do
        HTTParty.post("https://#{@host}/order/irn.php", :body => post)
      end

    logger.info 'Payu: ' + response.parsed_response.inspect
    ConfirmationResponse.new( response.parsed_response )
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
    validate! opts, :our_ref
    post = {}
    post[:REFNOEXT] = opts[:our_ref]
    add_merchant(post)

    post.slice!(*STATE_PARAMS_ORDER)
    post[:HASH] = hash_string(@seller_key, post)

    response =
      benchmark 'Payu IOS' do
        HTTParty.get("https://#{@host}/order/ios.php", :query => post)
      end

    logger.info 'Payu: ' + response.parsed_response.inspect
    StateResponse.new( response.parsed_response )
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  def add_creditcard(post, creditcard)
    post[:CC_NUMBER] = creditcard.number
    post[:CC_TYPE] =
      case creditcard.type
      when 'master'
        'MasterCard'
      when 'maestro'
        'MAESTRO'
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

  def alu_add_money(post, money)
    post[:ORDER_PRICE] = [money.to_s]
    post[:PRICES_CURRENCY] = 'RUB'
  end

  def idn_add_money(post, money)
    post[:ORDER_AMOUNT] = sprintf("%.2f", money)
    post[:ORDER_CURRENCY] = 'RUB'
  end

  def time_now_string
    Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
  end

  def add_custom_fields(post, custom_fields)
    post[:ORDER_PNAME] = ['1 x Ticket']
    post[:ORDER_PCODE] = ['TCK1']
    post[:ORDER_PINFO] = [serialize_order_info(custom_fields)]
    post[:ORDER_QTY] = ['1']
    post[:ORDER_VAT] = ['0']
    post[:PAY_METHOD] = 'CCVISAMC'

    post.merge!(
      :BILL_LNAME            => custom_fields.last_name || "",
      :BILL_FNAME            => custom_fields.first_name || "",
      :BILL_ADDRESS          => 'Address Eviterra',        #billing customer address
      :BILL_CITY             => 'City',                    #billing customer city
      :BILL_STATE            => 'State',                   #billing customer State
      :BILL_ZIPCODE          => '123',                     #billing customer Zip
      :BILL_EMAIL            => custom_fields.email,
      :BILL_PHONE            => custom_fields.phone,
      :BILL_COUNTRYCODE      => 'RU',                      #billing customer 2 letter country code
      :CLIENT_IP             => custom_fields.ip,

      :DELIVERY_LNAME        => custom_fields.last_name || "",
      :DELIVERY_FNAME        => custom_fields.first_name || "",
      :DELIVERY_ADDRESS      => 'Address Eviterra',        #delivery address
      :DELIVERY_CITY         => 'City',                    #delivery city
      :DELIVERY_STATE        => 'State',                   #delivery state
      :DELIVERY_ZIPCODE      => '123',                     #delivery Zip
      :DELIVERY_PHONE        => custom_fields.phone,
      :DELIVERY_COUNTRYCODE  => 'RU',                      #delivery 2 letter country code
    )
  end

  def serialize_order_info(custom_fields)
    info = {}
    info['reservationcode'] = custom_fields.pnr_number
    info['passengername'] = custom_fields.combined_name
    if custom_fields.date && custom_fields.points
      # WTF integer? но так в их примерах.
      info['departuredate'] = custom_fields.date.strftime('%Y%m%d').to_i
      info['locationnumber'] = custom_fields.points.size
      custom_fields.points.each_with_index do |iata, index|
        info["locationcode#{index + 1}"] = iata
      end
    end
    info.delete_if{ |k,v| v.nil? }.to_json
  end

  # for testing purposes
  def self.test_card(opts = {})
    CreditCard.new(
      {:number => '4111111111111111', :verification_value => '123', :year => 2013, :month => 12, :name => 'card one'}.merge(opts)
    ).tap(&:valid?)
  end

end
