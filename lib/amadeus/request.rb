# encoding: utf-8
module Amadeus::Request

  SOAP_ACTIONS = YAML.load_file(File.expand_path("../soap_actions.yml",  __FILE__))
  # 'AirMultiAvailability' => 'Air_MultiAvailability'
  SOAP_ACTIONS_FOR_CLASS = Hash[ SOAP_ACTIONS.keys.map {|action| [action.camelize, action] }]

  def self.for action
    "::Amadeus::Request::#{action.camelize}".constantize
  # rescue NameError
  #  Amadeus::Request::Base
  end

  def self.wrap(action, *args)
    if args.first.is_a? Amadeus::Request::Base
      args.first
    else
      Amadeus::Request.for(action).new(*args)
    end
  end


  class Base

    include KeyValueInit

    # soap headers

    def action
      @action ||= SOAP_ACTIONS_FOR_CLASS[self.class.name.gsub(/^.*::/,'')]
    end

    def soap_action
      SOAP_ACTIONS[action]['soap_action']
    end

    # все, кроме Security_Authenticate
    def needs_session?
      true
    end

    # response handling
    def process_response(*args)
      Amadeus::Response.for(action).new(*args)
    end

    # request template rendering

    def soap_body
      "\n  " +
      if File.file?(haml_template(action))
        render_haml( haml_template(action), self)
      elsif File.file?(xml_template(action))
        render_xml(xml_template(action))
      else
        raise "no template found for action #{action}"
      end
    end

    def xml_template(action);  File.expand_path("../templates/#{action}.xml",  __FILE__) end
    def haml_template(action); File.expand_path("../templates/#{action}.haml", __FILE__) end

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

  end

end
