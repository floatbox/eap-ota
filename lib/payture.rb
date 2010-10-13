require 'openssl'
require 'base64'
require 'httparty'

class Payture

  HOST = 'engine-sandbox.payture.com'
  PEM = <<-"END".gsub(/^\s*/,'')
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ
    8AMIIBCgKCAQEAwebFFBxoAUkFL48Ag8OA
    7aVOsjjx2ohJGQzPOv0HD8TkkjTpE3NAsTPhz7VQHdaMT2Gbaz4ueT/J2VpkXd4E
    Zs4RbjFSe4tkT30GTougWe7xstnRbVPekvWoL5GBnW1fqXvcaLcF4Sw8My2ovbVm
    szNaNrkUl+/qHeo9GPbo6tUSedMj+EybKBqqdoQjPwNEESbxWV2KFFhGz4Pkhy5t
    NHbgRmc1NDEXNte5KfZzNTtiqFbHDRC+nOskj/mvJlv2DqlugMI2lBtfpRnkcF8M
    f1cYvvC7eERx5sNAscUqQQnEsXm5wCZOX+g/9kK4NgaDeVr+C4QGqo+Wzk1n1gI/
    WQIDAQAB
    -----END PUBLIC KEY-----
  END

  def initialize(opts={})
    @key = opts[:key] || 'MerchantETerra'
    @host = opts[:host] || HOST
    @public = OpenSSL::PKey::RSA.new(opts[:pem] || PEM)
  end

  def pay amount, card, opts={}
    post = {}
    add_order(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    encrypt_payinfo(post)

    #args = {:Key => @key, :PayInfo => encode_pay_info(opts), :OrderId => opts[:OrderId], :Amount => opts[:Amount]}
    response = post_request 'Pay', post
  end

  # блокировка средств на карте пользователя
  def block amount, card, opts={}
    post = {}
    add_order(post, opts)
    add_money(post, amount)
    add_merchant(post)
    add_creditcard(post, card)
    encrypt_payinfo(post)
    
    response = post_request 'Block', post
    
  end

  # завершение платежа со списанием средств с карты пользователя
  #def charge opts={}
  #  args = {:Key => @key, :OrderId => opts[:OrderId]}
  #  response = post 'Charge', args
  #end

  ## изменить сумму средств, заблокированных на карте пользователя
  #def unblock amount, opts={}
  #  args = {:Key => @key, :OrderId => opts[:OrderId], :Amount => opts[:Amount]}
  #  response = post 'Unblock', args
  #end

  ## возврат средств (полный или частичный) на карту пользователя
  #def refund amount, opts={}
  #  args = {:Key => @key, :OrderId => opts[:OrderId], :Amount => opts[:Amount]}
  #  response = post 'Refund', args
  #end

  ## уточнение текущего состояния платежа
  #def status opts
  #  args = {:Key => @key, :OrderId => opts[:OrderId]}
  #  response = post 'GetStatus', args
  #end

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
    # похэндлить преобразование к копейкам?
    post[:Amount] = money.to_i.to_s
  end

  def encrypt_payinfo(post)
    keys = [:PAN, :EMonth, :EYear, :CardHolder, :SecureCode, :OrderId, :Amount]
    validate! post, *keys
    pay_info_string = keys.collect {|k| "#{k}=#{post[k]}" }.join(';')
    post[:PayInfo] = Base64::encode64( encrypt(pay_info_string) ).rstrip
    [:PAN, :EMonth, :EYear, :CardHolder, :SecureCode].each {|key| post.delete(key) }
  end

  def encrypt(string)
    @public.public_encrypt(string)
  end
end

def card1(opts = {})
  {:PAN => '4111111111111112', :SecureCode => '123', :EMonth => '10', :EYear => '10', :CardHolder => 'card one'}.merge(opts)
end

def card2(opts = {})
  {:PAN => '5222230546300090', :SecureCode => '123', :EMonth => '10', :EYear => '10', :CardHolder => 'card two'}.merge(opts)
end
