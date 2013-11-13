class Alfastrah
  attr_accessor :host, :base_url

  PRODUCTS = {
    flight: 'EVITERRA-FLIGHT',
    travel: 'EVITERRA-TRAVEL'
  }

  def host
    @host ||= Conf.alfastrah.host
  end

  def base_url
    @base_url ||= Conf.alfastrah.base_url
  end

  def calculate *args
    request = Alfastrah::Calculation::Request.new *args
    response = post request.endpoint, request.build_xml
    Alfastrah::Calculation::Response.new response.body
  end

  def purchase *args
    request = Alfastrah::Purchase::Request.new *args
    response = post request.endpoint, request.build_xml
    response = Alfastrah::Purchase::Response.new response.body

    request = Alfastrah::Confirmation::Request.new policy_id: response.policy_id
    response = post request.endpoint, request.build_xml
    Alfastrah::Confirmation::Response.new response.body
  end

  private

  def post endpoint, body
    transport = Net::HTTP.new(host, 443)
    transport.use_ssl = true
    transport.ssl_version = :SSLv3
    transport.verify_mode = OpenSSL::SSL::VERIFY_NONE # нужно выключить, когда они починят сертификат
    transport.request_post [base_url, endpoint].join('/'), body
  end
end
