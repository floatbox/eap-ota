# -*- encoding: utf-8 -*-

#require 'handsoap'
#require 'haml'
#require 'yaml'
class Amadeus < Handsoap::Service

  class AmadeusError < StandardError

  end

  include FileLogger
  #cattr_accessor :fake
  def self.fake=(value); $amadeus_fake=value; end
  def self.fake; $amadeus_fake; end
  #Handsoap.http_driver = :http_client
  Handsoap.timeout = 500

  # handsoap logger
  fh = open(Rails.root + 'log/amadeus.log', 'a')
  fh.sync=true
  self.logger = fh

  endpoint :uri => "https://test.webservices.amadeus.com", :version => 1

  attr_accessor :session

  # дефолтный инстанс, который используется для Amadeus.method, вызывает
  # new без аргументов.
  def initialize(args = {})
    if args[:book]
      self.session = AmadeusSession.book
    elsif args[:session]
      self.session = args[:session]
    end
  end

  def on_response_document(doc)
    doc.add_namespace 'header', 'http://webservices.amadeus.com/definitions'
    doc.add_namespace 'soap', envelope_namespace
    # works on :nokogiri driver only
    # TODO replace with .first.namespace on never handsoap
    result_namespace = (doc / '//soap:Body/*').first.native_element.namespace.href
    doc.add_namespace 'r', result_namespace
  end

  def invoke_rendered action, opts={}

    args = opts[:args]
    if args.is_a? Hash
      args = OpenStruct.new({:debug => false}.merge(args))
    end

    if Amadeus.fake || opts[:debug] || args.try(:debug)
      xml_string = read_xml(action)
      response = parse_string(xml_string)
    else
      soap_body = render(action, args)
      #save_xml('request_'+ action, soap_body)
      response = nil
      # WTF по каким-то неясным причинам без :: ломается development mode
      # 'Amadeus module is not active or removed'
      ::AmadeusSession.with_session(session) do |booked_session|
        @@request_time = Benchmark.ms do
          response = invoke(action,
            :soap_action => opts[:soap_action],
            :soap_header => {'SessionId' => booked_session.session_id} ) do |body|
            body.set_value soap_body, :raw => true
          end
        end
      end
      save_xml(action, response.to_xml)
    end

    #if opts[:r]
    #  response.add_namespace 'r', opts[:r]
    #end
    # first element in envelope root
    response_body = response.xpath('soap:Envelope/soap:Body/*').first

    if (response_body / 'r:errorMessage').present?
      raise AmadeusError, "#{ response_body / '//r:error' }: #{response_body / '//r:description'}"
    end

    response_body
  end

  cattr_reader :request_time
  def self.reset_request_time
    @@request_time = 0
  end

  def xml_template(action); "xml/#{action}.xml" end
  def haml_template(action); "haml/#{action}.haml" end

  def render(action, locals={})
    if File.file?(haml_template(action))
      render_haml( haml_template(action), locals)
    elsif File.file?(xml_template(action))
      render_xml(xml_template(action))
    else
      raise "no template found for action #{action}"
    end
  end

  def render_haml(template, locals={})
    Haml::Engine.new(File.read(template)).render(locals)
  end

  def render_xml(template)
    # locals ignored
    File.read(template)
  end

  def security_authenticate
    payload = render('Security_Authenticate')
    response = invoke(
      'Security_Authenticate',
      :soap_action => 'http://webservices.amadeus.com/1ASIWOABEVI/VLSSLQ_06_1_1A'
    ) { |body| body.set_value( payload, :raw => true) }

    response.add_namespace 'r', 'http://xml.amadeus.com/VLSSLR_06_1_1A'

    if (response / '//r:statusCode').to_s == 'P'
       (response / '//header:SessionId').to_s
    end
  end

  def security_sign_out(session)
    # у запроса пустое тело
    response = invoke(
      'Security_SignOut',
      :soap_action => 'http://webservices.amadeus.com/1ASIWOABEVI/VLSSOQ_04_1_1A',
      :soap_header => {'SessionId' => session.session_id}
    )

    response.add_namespace 'r', "http://xml.amadeus.com/VLSSOR_04_1_1A"

    # нужно ли ловить тип ошибки?
    (response / '//r:statusCode').to_s == 'P'
  end

  def fare_master_pricer_calendar(args)
    soap_action 'Fare_MasterPricerCalendar', args
  end

  def fare_master_pricer_travel_board_search(args)
    soap_action 'Fare_MasterPricerTravelBoardSearch', args
  end

  def pnr_add_multi_elements(args)
    soap_action 'PNR_AddMultiElements', args
  end

  def pnr_retrieve(args)
    ::AmadeusSession.with_session(session) do
      # FIXME почему сессия не используется?
      r = soap_action 'PNR_Retrieve', args
      # cmd('IG')
      soap_action 'PNR_AddMultiElements', :ignore => true
      r
    end
  end

  def doc_issuance_issue_ticket(args)
    soap_action 'DocIssuance_IssueTicket', args
  end

  def fare_price_pnr_with_lower_fares(args)
    soap_action 'Fare_PricePNRWithLowerFares', args
  end

  def fare_informative_pricing_without_pnr(args)
    soap_action 'Fare_InformativePricingWithoutPNR', args
  end

  def air_sell_from_recommendation(args)
    soap_action 'Air_SellFromRecommendation', args
  end

  def command_cryptic(args)
    soap_action 'Command_Cryptic', args
  end

  def cmd(command)
    response = soap_action('Command_Cryptic', :command => command)
    response.xpath('//r:textStringDetails').to_s
  end

  def soap_action(action, args = nil)
    yml = YAML::load(File.open(RAILS_ROOT+'/config/soap_actions.yaml'))
    response = invoke_rendered action,
      :soap_action => yml[action]['soap_action'],
      :r => yml[action]['soap_action'],
      :args => args
  end

  # for debugging of handsoap parser
  def parse_string(xml_string)
    doc = Handsoap::XmlQueryFront.parse_string(xml_string, :nokogiri)
    on_response_document(doc)
    doc
  end

end

