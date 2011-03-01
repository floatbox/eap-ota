# encoding: utf-8
require 'openssl'
require 'base64'
require 'httparty'

class Payture

  # комиссионные за транзакцию
  def self.commission(price)
    pcnt = 0.0325
    ((CBR.usd(0.10) + pcnt * price) / ( 1 - pcnt)).round(2)
  end

  class Response
    def initialize(doc)
      @doc = doc
    end

    def success?
      @doc["Success"] == "True"
    end

    def err_code
      @doc["ErrCode"]
    end

    # не !success? потому что может быть и "3DS"
    def error?
      @doc["Success"] == "False"
    end

    def order_id
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
      @doc["Success"] == "3DS"
    end

    def acs_url
      @doc["ACSUrl"]
    end

    def pa_req
      @doc["PaReq"]
    end

    def threeds_key
      @doc["ThreeDSKey"]
    end

    # GetState
    # 'PreAuthorized3DS', 'Voided', 'Rejected', какие еще?
    def state
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
  def state opts={}
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
    validate! options, :order_id
    post[:OrderId] = options[:order_id]
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
end
