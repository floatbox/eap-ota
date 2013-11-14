class Alfastrah
  attr_reader :host, :base_url, :errors

  PRODUCTS = {
    flight: 'EVITERRA-FLIGHT',
    travel: 'EVITERRA-TRAVEL'
  }

  def initialize options = {}
    @host     = options.fetch :host,     Conf.alfastrah.host
    @base_url = options.fetch :base_url, Conf.alfastrah.base_url
  end

  def calculate params
    get_response Alfastrah::Calculation, params
  end

  def purchase params
    purchase_response = get_response Alfastrah::Purchase, params
    return unless purchase_response

    confirm_response = get_response Alfastrah::Confirmation, policy_id: purchase_response.policy_id
    confirm_response.policy_id = purchase_response.policy_id
    confirm_response
  end

  def info params
    get_response Alfastrah::Info, params
  end

  private

  def get_response action, params
    @errors  = nil
    request  = action.const_get('Request', false).new params
    response = post request
    response = action.const_get('Response', false).new response.body

    if response.success?
      response
    else
      @errors = response.errors
      false
    end
  end

  def post request
    transport = Net::HTTP.new(host, 443)
    transport.use_ssl = true
    transport.ssl_version = :SSLv3
    transport.verify_mode = OpenSSL::SSL::VERIFY_NONE # нужно выключить, когда они починят сертификат
    transport.request_post [base_url, request.endpoint].join('/'), request.build_xml
  end
end
