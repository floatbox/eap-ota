# -*- encoding: utf-8 -*-
module Amadeus

  class Service < Handsoap::Service

  endpoint :uri => Conf.amadeus.endpoint, :version => 1

  # сжатие
  #require 'handsoap/compressed_curb_driver'
  #Handsoap.http_driver = :compressed_curb
  #require 'handsoap/typhoeus_driver'
  #Handsoap.http_driver = :typhoeus
  require 'handsoap/multi_curb_driver'
  Handsoap.http_driver = :multicurb

  Handsoap.timeout = 60


  # response logger
  include FileLogger
  def debug_dir; 'log/amadeus' end

  # handsoap logger
  if Conf.amadeus.logging
    self.logger = open(Rails.root + 'log/amadeus.log', 'a').tap { |fh| fh.sync = true }
  end

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

  # include ActiveSupport::Benchmarkable

  # # не то же самое, что и self.logger=. используется для benchmark
  # def logger
  #   Rails.logger
  # end

  # def parse_http_response(*)
  #   benchmark 'Handsoap::Parser: parsing response' do
  #     super
  #   end
  # end

  delegate :release, :destroy, :to => :session

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
      xml_string = read_latest_log_file(request.action)
      xml_response = parse_string(xml_string)
    else
      if session.nil? && request.needs_session?
        raise ArgumentError, 'called without session'
      end
      invoke_opts = {}
      invoke_opts[:soap_action] = request.soap_action
      invoke_opts[:soap_header] = {'SessionId' => session.session_id} if session
      xml_response = invoke(request.action, invoke_opts) do |body|
        body.set_value request.soap_body, :raw => true
      end
      # FIXME среагировать на HTTP error
      session.increment if session
      log_file(request.action, xml_response.to_xml)
    end

    request.process_response(xml_response)
  end

  def invoke_async_request request, &on_success
    Rails.logger.info "Amadeus::Service: #{request.action} async queued"
    invoke_opts = {}
    invoke_opts[:soap_action] = request.soap_action
    invoke_opts[:soap_header] = {'SessionId' => session.session_id}

    if Conf.amadeus.fake
      xml_string = read_latest_log_file(request.action)
      xml_response = parse_string(xml_string)
      on_success.call( request.process_response(xml_response) )

    else
      callbacks = Proc.new do |deffered|
        deffered.callback &on_success
        deffered.errback do |err|
          Rails.logger.error "Amadeus::Service: async: #{err.inspect}"
        end
      end

      async(callbacks) do |dispatcher|
        dispatcher.request(request.action, invoke_opts) do |body|
          body.set_value request.soap_body, :raw => true
        end
        dispatcher.response do |xml_response|
          session.increment
          request.process_response(xml_response)
        end
      end
    end
  end

  # fare_master_pricer_travel_board_search
  Amadeus::Request::SOAP_ACTIONS.keys.each do |action|
    # Amadeus::Service.pnr_add_multi_elements etc.
    define_method action.underscore do |*args|
      invoke_request Amadeus::Request.wrap(action, *args)
    end

    define_method "async_#{action.underscore}" do |*args, &block|
      invoke_async_request Amadeus::Request.wrap(action, *args), &block
    end
  end

# метрика

  include NewRelic::Agent::MethodTracer
  add_method_tracer :log_file, 'Custom/Amadeus/log'
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
    xml_string = read_latest_log_file(action)
    parse_string(xml_string)
  end

  def read_each_doc(action)
    read_each_log_file(action) do |xml, path|
      yield parse_string(xml), path
    end
  end

  end

end
