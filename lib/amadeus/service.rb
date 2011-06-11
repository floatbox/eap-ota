# -*- encoding: utf-8 -*-
module Amadeus

  class Service < Handsoap::Service

  endpoint :uri => Conf.amadeus.endpoint, :version => 1

  # сжатие
  require 'handsoap/compressed_curb_driver'
  Handsoap.http_driver = :compressed_curb
  #require 'handsoap/typhoeus_driver'
  #Handsoap.http_driver = :typhoeus

  Handsoap.timeout = 500


  # response logger
  include FileLogger
  def debug_dir; 'log/amadeus' end

  # handsoap logger
  fh = open(Rails.root + 'log/amadeus.log', 'a')
  fh.sync=true
  self.logger = fh

  attr_accessor :session

  # дефолтный инстанс, который используется для Amadeus.method, вызывает
  # new без аргументов.
  def initialize(args = {})
    if args[:book]
      self.session = Amadeus::Session.book(args[:office])
    elsif args[:session]
      self.session = args[:session]
    end
  end

  delegate :release, :to => :session

# generic helpers

  # вынесены во внешний модуль, чтобы методы можно было оверрайдить
  include Amadeus::SOAPActions
  include Amadeus::Macros

  def on_response_document(doc)
    doc.add_namespace 'header', 'http://webservices.amadeus.com/definitions'
    doc.add_namespace 'soap', envelope_namespace
    result_namespace = (doc / '//soap:Body/*').first.node_namespace
    doc.add_namespace 'r', result_namespace
  end

  def invoke(*)
    debug '==============='
    debug "unixtime: #{Time.now.to_i}"
    super
  end

  def invoke_rendered action, opts={}

    request = opts[:request]

    if Conf.amadeus.fake
      xml_string = read_latest_xml(action)
      response = parse_string(xml_string)
    else
      soap_body = render(action, request)
      response = nil
      Amadeus::Session.with_session(session) do |booked_session|
        response = invoke(action,
          :soap_action => opts[:soap_action],
          :soap_header => {'SessionId' => booked_session.session_id} ) do |body|
          body.set_value soap_body, :raw => true
        end
      end
      save_xml(action, response.to_xml)
    end

    response
  end


# request template rendering

  def xml_template(action);  File.expand_path("../templates/#{action}.xml",  __FILE__) end
  def haml_template(action); File.expand_path("../templates/#{action}.haml", __FILE__) end

  def render(action, locals=nil)
    "\n  " +
    if File.file?(haml_template(action))
      render_haml( haml_template(action), locals)
    elsif File.file?(xml_template(action))
      render_xml(xml_template(action))
    else
      raise "no template found for action #{action}"
    end
  end

  def render_haml(template, locals=nil)
    Haml::Engine.new( File.read(template),
      :autoclose => [],
      :preserve => [],
      :filename => template,
      :ugly => false,
      :escape_html => true
    ).render(locals)
  end

  def render_xml(template)
    # locals ignored
    File.read(template)
  end

# sign in and sign out sessions

  # оверрайд методов из SOAPACTions
  def security_authenticate(office)
    request = Amadeus::Request::SecurityAuthenticate.new(:office => office)
    payload = render('Security_Authenticate', request)
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
    # у запроса пустое тело, поэтому оверрайдим SOAPActions
    response = invoke(
      'Security_SignOut',
      :soap_action => 'http://webservices.amadeus.com/1ASIWOABEVI/VLSSOQ_04_1_1A',
      :soap_header => {'SessionId' => session.session_id}
    )

    response.add_namespace 'r', "http://xml.amadeus.com/VLSSOR_04_1_1A"

    # нужно ли ловить тип ошибки?
    (response / '//r:statusCode').to_s == 'P'
  end

# метрика

  include NewRelic::Agent::MethodTracer
  add_method_tracer :save_xml, 'Custom/Amadeus/log'
  add_method_tracer :debug, 'Custom/Amadeus/log'
  add_method_tracer :parse_soap_response_document, 'Custom/Amadeus/xmlparse'
# debugging

  # for debugging of handsoap parser
  def parse_string(xml_string)
    doc = Handsoap::XmlQueryFront.parse_string(xml_string, :nokogiri)
    on_response_document(doc)
    doc
  end

  def read_latest_doc(action)
    xml_string = read_latest_xml(action)
    parse_string(xml_string)
  end

  def read_each_doc(action)
    read_each_xml(action) do |xml, path|
      yield parse_string(xml), path
    end
  end

  end

end
