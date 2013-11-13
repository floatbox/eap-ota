module Alfastrah
  URL_BASE = 'uat2.vtsft.ru'
  API_BASE = '/travel-ext-services/TravelExtService'

  PRODUCTS = {
    flight: 'EVITERRA-FLIGHT',
    travel: 'EVITERRA-TRAVEL'
  }

  def self.calculate *args
    request = Alfastrah::Calculation::Request.new *args
    response = post request.endpoint, request.build_xml
    Alfastrah::Calculation::Response.new response.body
  end

  def self.purchase *args
    request = Alfastrah::Purchase::Request.new *args
    response = post request.endpoint, request.build_xml
    response = Alfastrah::Purchase::Response.new response.body

    request = Alfastrah::Confirmation::Request.new policy_id: response.policy_id
    response = post request.endpoint, request.build_xml
    Alfastrah::Confirmation::Response.new response.body
  end

  private

  def self.post endpoint, body
    transport = Net::HTTP.new(URL_BASE, 443)
    transport.use_ssl = true
    transport.ssl_version = :SSLv3
    transport.verify_mode = OpenSSL::SSL::VERIFY_NONE # нужно выключить, когда они починят сертификат
    transport.request_post [API_BASE, endpoint].join('/'), body
  end
end
