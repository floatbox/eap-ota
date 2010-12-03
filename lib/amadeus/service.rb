# -*- encoding: utf-8 -*-
module Amadeus

  class Service < Handsoap::Service

  endpoint :uri => "https://test.webservices.amadeus.com", :version => 1
  #Handsoap.http_driver = :http_client
  Handsoap.timeout = 500

  # response logger
  include FileLogger
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

# generic helpers

  # вынесены во внешний модуль, чтобы методы можно было оверрайдить
  include Amadeus::SOAPActions

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
      Amadeus::Session.with_session(session) do |booked_session|
        response = invoke(action,
          :soap_action => opts[:soap_action],
          :soap_header => {'SessionId' => booked_session.session_id} ) do |body|
          body.set_value soap_body, :raw => true
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
      raise Amadeus::Error, "#{ response_body / '//r:error' }: #{response_body / '//r:description'}"
    end

    response_body
  end


# request template rendering

  def xml_template(action);  File.expand_path("../templates/#{action}.xml",  __FILE__) end
  def haml_template(action); File.expand_path("../templates/#{action}.haml", __FILE__) end

  def render(action, locals=nil)
    if File.file?(haml_template(action))
      render_haml( haml_template(action), locals)
    elsif File.file?(xml_template(action))
      render_xml(xml_template(action))
    else
      raise "no template found for action #{action}"
    end
  end

  def render_haml(template, locals=nil)
    Haml::Engine.new(File.read(template)).render(locals)
  end

  def render_xml(template)
    # locals ignored
    File.read(template)
  end


  def pnr_retrieve_and_ignore(args)
    pnr_retrieve(args)
  ensure
    pnr_ignore
  end

  # PNR, как он виден в системе
  def pnr_raw(pnr_number)
    cmd_full("RT#{pnr_number}") rescue $!.message
  ensure
    pnr_ignore
  end

  def pnr_ignore
    pnr_add_multi_elements :ignore => true
  end

  def pnr_ignore_and_retrieve
    # сделать опцию для pnr_add_multi_elements
    cmd("IR")
  end

  def pnr_commit
    pnr_add_multi_elements :end_transact => true
  end

  def pnr_commit_and_retrieve
    # сделать опцию для pnr_add_multi_elements
    cmd("ER")
  end

  def pnr_cancel
    cmd('XI')
  end

  def cmd(command)
    response = command_cryptic :command => command
    response.xpath('//r:textStringDetails').to_s
  end

  # работает только для очень некоторых команд
  def cmd_full(command)
    result = cmd(command)
    # заголовок
    result.sub!(/^(.*)\n/, '');
    if $1 == '/'
      # FIXME сделать класс для эксепшнов
      raise "Command_Cryptic: #{result.strip}"
    end
    # добываем следующие страницы, если есть
    while result.sub! /^\)\s*\Z/, ''
      # не обрезает заголовок второй и последующих страниц.
      # но разные команды выводят или не выводят в нем муру, эх
      result << cmd('MD')[2..-1]
    end
    result
  end

  # временное название для метода
  def self.issue_ticket(pnr_number)
    amadeus = Amadeus::Service.new(:book => true, :office => Amadeus::Session::TICKETING)
    amadeus.pnr_retrieve(:number => pnr_number)
    amadeus.doc_issuance_issue_ticket
  ensure
    amadeus.session.destroy
  end

  def give_permission_to_ticketing_office
    cmd("ES #{Amadeus::Session::TICKETING}-B")
  end

  def conversion_rate(currency_code)
    # BSR USED 1 USD = 30.50 RUB
    cmd("FQC 1 #{currency_code}") =~ /^BSR USED 1 ...? = ([\d.]+) RUB/
    $1.to_f if $1
  end

# sign in and sign out sessions

  # оверрайд методов из SOAPACTions
  def security_authenticate(office)
    payload = render('Security_Authenticate', OpenStruct.new(:office => office))
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


# debugging

  # for debugging of handsoap parser
  def parse_string(xml_string)
    doc = Handsoap::XmlQueryFront.parse_string(xml_string, :nokogiri)
    on_response_document(doc)
    doc
  end

  end

end
