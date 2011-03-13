# encoding: utf-8
require 'openssl'
require 'base64'
require 'httparty'

class Payonline
  # ����������: ������ ������������ �������� �������� ������ ������������ ���������� ContentType - text ��� xml. Text �������� �������� �� ���������.
  # ������ ����� ��������� �������������� ������� (� ��� ����� ������� csv ��� ������� list). Xml ������ �� ����� �����������: ������ ����� ���� ���������� ����������
  # � ������ �������. ���� ����� �������� �� ������������� � ��������, �������������� � md5 ����� �������������. ������� � ������ ��������� security key callback �������
  # ��������� capitalize ��� ���� ���������� ������ params. ����� ����, ��� ������������ capitalize ����� ������� �� ���� ������ Response ��� ������������� ����� binCountry
  # (������ �� ������� � ���������).

  # �� ������ ������ ���������� xml.

  # ��� �������, ����� auth (������ Post), ��������� ������������ � Get, � Post. ������ ��� ������� ���������� Post.

  # Payonline � ����� ������ ��������� ��������� ������ �� auth. � ��������� ������� ���� ��� �� ��� ���������� ������ bad request 400 ��� ���������. ��� ����� ����
  # ����������� ��� ���������� ���������� (��� ���������� ������� ���������), ��� �, ��������, ���� ������ �������������� �� ����� ���� transaction_id ��� �������� void.
  # ��� ��� ��������� � ���������� ����� ����� ��������.
  # ����� search �� ������ ������ ���� �� �������������� ��������.
  # ��� complete �������� ���-���� ����� bad request �� ������. ��������, �����-�� ��������� � idata.

  class Response
    def initialize(doc)
      @doc = doc && doc.inject({}) { |h, (k, v)| h[k == 'binCountry' ? k : k.capitalize] = v; h } || {}
    end

    def success?
      @doc["Result"] == "Ok"
    end
    
    # ����� ���������� ����� � ��� �������� ��������, �������� ��������� err_code ��� ������������� � payture.
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

    # new_amount �����������, �.�. void �� ������������ ��������� �������������, � refund �� ���������� ���������� ����� �����

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

  # ��������� ������� � ���� ��� � � ��� ���� ����������� � PayOnline ����� � ��� �� �������� auth � ����������� �� �������� �������� �������, ������ � ���� �������� ���
  # ���������� ���, ��������� �� �������� IData �� ������ ���������� ��� �� �� ������ ���������� �������. ����� ������������ Conf.payonline.preauthorization.
  # � ������ ������ ��������� ������, �� ���������� nil (��� ������������� ����� ���������� �� exception).
  # �������� �������� ������ ("RUB", "EUR", "USD"), �� ��������� ���������� �����.
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

  # ���������� ������� �� ����� ������������.
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

  # �������� ������� ��� ����������� ������� � ������ ����������� �������. ��������� ��������� ��������; �� ��������� ����������� ��� �����.
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

  # ������������� ������� (� ��� �����, ���� ��� ��� �� ������ ��������� �� ������� � ���� ���).
  # ��������� ������������� ����������; �������� amount �������� ��� ������������� � payture.
  def unblock amount, opts={}
    validate! opts, :transaction_id
    post = {}
    add_merchant_id(post)
    add_transaction_id(post, opts)
    add_security_key(post)

    post_request 'transaction/void', post
  end

  # ��������� ����� � ��������� ����� �����. ����������� ������ �������� ����������� �� ������ ��������� ��������.
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

  # ������� ������� (������ ��� ���������) �� ����� ������������ � ������ �������. ����� ������ ���� ������� ���� � ������ �������� ���� �����.
  def refund amount, opts={}
    validate! opts, :transaction_id
    post = {}
    add_merchant_id(post)
    add_transaction_id(post, opts)
    add_money(post, amount)
    add_security_key(post)

    post_request 'transaction/refund', post
  end

  # ��������� �������� ��������� �������. ����� ������� ���� order_id, ���� transaction_id.
  def state opts={}
    post = {}
    add_merchant_id(post)
    add_order_id(post, opts) || add_transaction_id(post, opts)
    add_security_key(post)

    post_request 'search', post
  end

  # ���������� ������ ���� ���������� �� ���������.
  def list opts={}
    validate! opts, :date_from, :date_till, :type, :status
    post = {}
    add_merchant_id(post)
    add_filters(post, opts)
    add_security_key(post)

    post_request 'transaction/list', post
  end

  # �������� ���������� security key callback ������� � ��������� ����������� �������� Payonline (� ��� ����� ���������� private security key).
  # ��������� params, ������� ��� ������������� ������ ������� ������ ������������� Payonline::Response.new.
  def valid_security_key?(params)
    params["securityKey"] == md5(params.inject({}) { |h, (k, v)| h[k.capitalize] = v; h })
  end

  private
  def validate! opts, *required_keys
    unless (required_keys & opts.keys) == required_keys
      raise ArgumentError, "#{(required_keys - opts.keys).join(', ')} opts are missing"
    end
  end

  # �� ������� ������������ ������ Payonline ����� ���������� ����� ���������� (��� search ������������� �� ����������� transaction), ������� ����������� ������ � ������
  # (��������, "transaction/auth").
  def post_request action, args
    debug args.inspect
    response = HTTParty.post("https://#{@host}/payment/#{action}/", :body => args.merge(:ContentType => "xml"), :format => :xml)
    debug response.parsed_response.inspect
    if action == 'transaction/list'
      # list ���������� ������ ���������; ������ �� ��� ����������������� � Response.
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
    # C������ ��������� ����� ������ � ����� ����������� �������.
    post[:Amount] = "%.2f" % money if money
  end

  def add_currency(post, currency)
    post[:Currency] = currency
  end

  # ���������� ����� ��������� ����������.
  def add_rebill_anchor(post, opts)
    post[:RebillAnchor] = opts[:rebill_anchor] if opts[:rebill_anchor]
  end

  # ���������� ������� ������ ���� 0192224171UTVOKUF+++++++++++++++++++++029861572262150080610VKOSALINA+NATALIA++++++
  # �� ������ ������ ��������� �����. ����� ����� ����� ��������� ������������ ������� ������ �� Payonline.
  def add_idata(post, opts)
    post[:IData] = opts[:idata] if opts[:idata]
  end

  # ����� ���������� ���������������� ������������ ����������, �����������c�� ������� ��������������� � �������� ������� ��������������� ��� ������� �����������.
  def add_contacts_and_location(post, opts)
    [:ip, :email, :country, :city, :address, :zip, :state, :phone].each {|key| post[key.to_s.camelcase.to_sym] = opts[key] if opts[key]}
  end
  
  # ���������� ��������, �������������� ����� �������� list. ���� ���������� � ����������� ������� yyyy-MM-dd. ������� � ����� ������ ���� �� ����� 3 ����.
  # status (PreAuthorized, Pending, Settled, Voided, Declined) � type (Purchase, Refund) ����� ����� �� ��������� ��������� ����� ��������.
  def add_filters(post, opts)
    [:date_from, :date_till, :type, :status].each {|key| post[key.to_s.camelcase.to_sym] = opts[key].to_s if opts[key]}
  end

  def add_security_key(post)
    post[:SecurityKey] = md5(post.merge(:PrivateSecurityKey => @private_security_key))
  end

  # ����������� ����������� ������ � md5 ��� security key; ����� �������������� � ��� ����� ��� �������� ���������� ����� � callback �������.
  def md5(post)
    keys = [:MerchantId, :TransactionId, :RebillAnchor, :OrderId, :Amount, :Currency, :DateFrom, :DateTill, :Type, :Status, :IData, :PrivateSecurityKey]
    Digest::MD5.hexdigest( keys.find_all{|k| post[k]}.collect {|k| "#{k}=#{post[k]}" }.join('&') )
  end

  def debug message
    Rails.logger.info "Payonline: #{message}"
  end

end