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

  endpoint :uri => "https://test.webservices.amadeus.com", :version => 1

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

    if Amadeus.fake || opts[:debug] || args.try(:debug)
      xml_string = read_xml(action)
      response = parse_string(xml_string)
    else
      soap_body = render(action, args)
      response = nil
      # WTF по каким-то неясным причинам без :: ломается development mode
      # 'Amadeus module is not active or removed'
      ::AmadeusSession.with_session(opts[:session]) do |session|
        @@request_time = Benchmark.ms do
          response = invoke(action,
            :soap_action => opts[:soap_action],
            :soap_header => {'SessionId' => session.session_id} ) do |body|
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
    template = File.read('xml/Security_Authenticate.xml')

    response = invoke 'Security_Authenticate',
      :soap_action => 'http://webservices.amadeus.com/1ASIWOABEVI/VLSSLQ_06_1_1A' do |body|
      body.set_value template, :raw => true
    end

    response.add_namespace 'r', 'http://xml.amadeus.com/VLSSLR_06_1_1A'

    if (response / '//r:statusCode').to_s == 'P'
       (response / '//header:SessionId').to_s
    end
  end

  # разлогинит какую-то случайную сессию, не деактивировав ее, притом. глупо.
  # TODO сделать по образцу security_authenticate
  def security_sign_out
    response = invoke_rendered 'Security_SignOut',
      :soap_action => "http://webservices.amadeus.com/1ASIWOABEVI/VLSSOQ_04_1_1A",
      :r => "http://xml.amadeus.com/VLSSOR_04_1_1A"

    (response / '//r:statusCode').to_s == 'P'
  end

  def fare_master_pricer_calendar(args)
    response = invoke_rendered 'Fare_MasterPricerCalendar',
      :soap_action => 'http://webservices.amadeus.com/1ASIWOABEVI/FMPCAQ_10_2_1A',
      :r => "http://xml.amadeus.com/FMPCAR_10_2_1A",
      :args => args
  end

  def fare_master_pricer_travel_board_search(args)
    response = invoke_rendered 'Fare_MasterPricerTravelBoardSearch',
      :soap_action => "http://webservices.amadeus.com/1ASIWOABEVI/FMPTBQ_09_1_1A",
      :r => "http://xml.amadeus.com/FMPTBR_09_1_1A",
      :args => args
  end

  def pnr_add_multi_elements(args)
    soap_action 'PNR_AddMultiElements', args
  end

  def pnr_retrieve(args, session=nil)
    soap_action 'PNR_Retrieve', args, session
  end

  def doc_issuance_issue_ticket(args, session=nil)
    soap_action 'DocIssuance_IssueTicket', args, session
  end

  def fare_price_pnr_with_lower_fares(args, session = nil )
    soap_action 'Fare_PricePNRWithLowerFares', args, session
  end
  
  def fare_informative_pricing_without_pnr(args, session = nil)
    soap_action 'Fare_InformativePricingWithoutPNR', args, session
  end

  def soap_action(action, args = nil, session = nil)
    yml = YAML::load(File.open(RAILS_ROOT+'/config/soap_actions.yaml'))
    response = invoke_rendered action,
      :soap_action => yml[action]['soap_action'],
      :r => yml[action]['soap_action'],
      :args => args,
      :session => session
  end

  # for debugging of handsoap parser
  def parse_string(xml_string)
    doc = Handsoap::XmlQueryFront.parse_string(xml_string, :nokogiri)
    on_response_document(doc)
    doc
  end

end

