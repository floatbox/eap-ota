# encoding: utf-8
require 'openssl'
require 'base64'
require 'httparty'

class Payture

  # комиссионные за транзакцию
  def self.commission(price)
    # 3.25% + 10c (3рубля), округляем до рублей
    (price * 0.0325 + 3).ceil
  end

  def config
    @@config ||= YAML.load_file(Rails.root + 'config/payture.yml')
  end

  def initialize(opts={})
    @key = opts[:key] || config[:key]
    @host = opts[:host] || config[:host]
    @public = OpenSSL::PKey::RSA.new(opts[:pem] || config[:pem])
  end

  def pay amount, card, opts={}
    post = {}
    add_order(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    encrypt_payinfo(post)

    result = post_request 'Pay', post
    debug "pay #{result.inspect}"
    result["Success"] == "True"
  end

  # блокировка средств на карте пользователя
  def block amount, card, opts={}
    post = {}
    add_order(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    encrypt_payinfo(post)

    result = post_request 'Block', post
    debug "block #{result.inspect}"
    result["Success"] == "True"
  end

  def charge opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    encrypt_payinfo(post)

    result = post_request 'Charge', post
    debug "charge #{result.inspect}"
    result["Success"] == "True"
  end

  # разблокировка средств.
  # частичная блокировка не принимается
  def unblock amount, opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    add_money(post, amount)
    encrypt_payinfo(post)

    result = post_request 'Unblock', post
    debug "unblock #{result.inspect}"
    result["Success"] == "True"
  end

  # возврат средств (полный или частичный) на карту пользователя
  # FIXME не получалось ни разу!
  def refund amount, opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    add_money(post, amount)

    result = post_request 'Refund', post
    debug "refund #{result.inspect}"
    result["Success"] == "True"
  end

  # уточнение текущего состояния платежа
  # {"Comment"=>"", "Tag"=>"", "LastChange"=>"11/12/2010 9:24:07 AM", "State"=>"Charged"}
  # "State"=>"Authorized", "Voided", "Charged"
  def status opts={}
    post = {}
    add_order(post, opts)
    add_merchant(post)
    encrypt_payinfo(post)

    post_request 'GetState', post
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  def post_request action, args
    response = HTTParty.post("http://#{@host}/api/#{action}/", :body => args, :format => :xml)
    response.parsed_response.values.first
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

  def add_money(post, money)
    # система принимает суммы в копейках
    post[:Amount] = (money.to_f * 100).ceil.to_s
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
    Rails.logger.debug "Payture: #{message}"
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
