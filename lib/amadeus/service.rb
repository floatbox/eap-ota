# -*- encoding: utf-8 -*-
require 'handsoap/multi_curb_driver'

module Amadeus

  class Service < Handsoap::Service

  endpoint :uri => Conf.amadeus.endpoint, :version => 1

  Handsoap.http_driver = :net_http
  Handsoap.timeout = 60
  # сохраняет xml из респонса as is,
  # без этого sax-парсер работать не будет
  Handsoap.store_raw_response = true

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
  include Monitoring::Benchmarkable

  def on_response_document(doc)
    doc.add_namespace 'header', 'http://webservices.amadeus.com/definitions'
    doc.add_namespace 'soap', envelope_namespace
    result_namespace = (doc / '//soap:Body/*').first.node_namespace
    doc.add_namespace 'r', result_namespace
  end

  def invoke(*)
    benchmark 'invoke request' do
      debug '==============='
      debug "unixtime: #{Time.now.to_i}"
      begin
        super
      rescue Curl::Err::CurlError, EOFError, Errno::ECONNRESET, SocketError
        raise Amadeus::NetworkError
      rescue Handsoap::Fault => e
        # TODO проверить бэктрейс и оригинальное сообщение об ошибке
        raise Amadeus::SoapError.wrap(e)
      end
    end
  end

  def invoke_request request

    ActiveSupport::Notifications.instrument( 'request.amadeus',
      service: self,
      request: request
    ) do |payload|
      payload[:xml_response] = invoke(request.action, invoke_opts(request)) do |body|
        body.set_value request.soap_body, :raw => true
      end
      # FIXME среагировать на HTTP error
      # FIXME или перенести в ensure, не забыв поправить Amadeus::LogSubscriber
      session.increment if session

      payload[:response] = request.process_response( payload[:xml_response] )
    end
  end

  def invoke_async_request request, &on_success
    ActiveSupport::Notifications.instrument( 'async_request.amadeus' ) do |async_payload|

      callbacks = Proc.new do |deffered|
        deffered.callback &on_success
        deffered.errback do |err|
          # WTF: никогда не вызывается. Возможно, баг в multicurb-драйвере
        end
      end

      async(callbacks) do |dispatcher|
        dispatcher.request(request.action, invoke_opts(request)) do |body|
          body.set_value request.soap_body, :raw => true
        end
        dispatcher.response do |xml_response|
          # FIXME сейчас будет активно врать про duration запроса. В четвертых рельсах
          # есть instrumenter.start и finish, позволит замерять время адекватнее
          ActiveSupport::Notifications.instrument( 'request.amadeus',
            service: self,
            request: request,
            xml_response: xml_response
          ) do |payload|
            session.increment
            payload[:response] = request.process_response(xml_response)
          end
        end
      end

    end
  end

  def invoke_opts(request)
    if session.nil? && request.needs_session?
      raise ArgumentError, 'called without session'
    end
    invoke_opts = {}
    invoke_opts[:soap_action] = request.soap_action
    invoke_opts[:soap_header] = {'SessionId' => session.session_id} if session
    invoke_opts
  end
  private :invoke_opts

  # Amadeus::Service#pnr_add_multi_elements etc.
  Amadeus::Request::SOAP_ACTIONS.keys.each do |action|
    eval <<-"END", nil, __FILE__, __LINE__
      def #{action.underscore} (*args)
        invoke_request Amadeus::Request.wrap( #{action.inspect}, *args)
      end

      def async_#{action.underscore} (*args, &block)
        invoke_async_request Amadeus::Request.wrap( #{action.inspect}, *args), &block
      end
    END
  end

# метрика

  include NewRelic::Agent::MethodTracer
  add_method_tracer :debug, 'Custom/Amadeus/log'
  add_method_tracer :parse_soap_response_document, 'Custom/Amadeus/xmlparse'
# debugging

  # for debugging of handsoap parser
  def parse_string(xml_string)
    doc = Handsoap::XmlQueryFront.parse_string(xml_string, :nokogiri)
    on_response_document(doc)
    doc
  end

  end

end
