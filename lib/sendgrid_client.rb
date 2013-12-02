class SendgridClient
  AUTH_BODY = {
    api_user: Conf.sendgrid.username,
    api_key: Conf.sendgrid.password
  }

  attr_accessor :host, :base_url

  def initialize options = {}
    @host     = options.fetch :host,     Conf.sendgrid.api['host']
    @base_url = options.fetch :base_url, Conf.sendgrid.api['base_url']
  end

  def bounces options = {}
    body = options.slice(:email, :date_start, :date_end)
    request('bounces.get.json', body)
  end

  def blocks options = {}
    body = options.slice(:email, :date_start, :date_end)
    request('blocks.get.json', body)
  end

  def invalidemails options = {}
    body = options.slice(:email, :date_start, :date_end)
    request('invalidemails.get.json', body)
  end

  private

  def request endpoint, options = {}
    return false unless Conf.sendgrid.enabled
    transport = Net::HTTP.new(host, 443)
    transport.use_ssl = true

    body = AUTH_BODY.merge(options).to_param
    response = transport.request_post [base_url, endpoint].join('/'), body
    MultiJson.load response.body
  end
end
