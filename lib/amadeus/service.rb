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
    @driver = args[:driver]
  end

  def http_driver_instance
    @driver || super
  end

  delegate :release, :to => :session

# generic helpers

  # вынесены во внешний модуль, чтобы методы можно было оверрайдить
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

  def invoke_request request

    Rails.logger.info "Amadeus::Service: #{request.action} started"

    xml_response = nil
    if Conf.amadeus.fake
      xml_string = read_latest_xml(request.action)
      xml_response = parse_string(xml_string)
    else
      if request.needs_session?
        Amadeus::Session.with_session(session) do |booked_session|
          xml_response = invoke(request.action,
            :soap_action => request.soap_action,
            :soap_header => {'SessionId' => booked_session.session_id} ) do |body|
            body.set_value request.soap_body, :raw => true
          end
        end
      else
        xml_response = invoke(request.action,
          :soap_action => request.soap_action) do |body|
          body.set_value request.soap_body, :raw => true
        end
      end
      save_xml(request.action, xml_response.to_xml)
    end

    request.process_response(xml_response)
  end

  # fare_master_pricer_travel_board_search
  Amadeus::Request::SOAP_ACTIONS.keys.each do |action|
    # Amadeus::Service.pnr_add_multi_elements etc.
    define_method action.underscore do |*args|
      invoke_request Amadeus::Request.wrap(action, *args)
    end

    define_method "async_#{action.underscore}" do |*args, &block|
      invoke_async_request Amadeus::Request.wrap(action, *args, &block)
    end
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
