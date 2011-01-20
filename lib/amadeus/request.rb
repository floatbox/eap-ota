module Amadeus::Request

  def self.for action
    "::Amadeus::Request::#{action.camelize}".constantize
  rescue NameError
    Amadeus::Request::Base
  end

  class Base #< OpenStruct

    include KeyValueInit
    attr_accessor :debug
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
      Haml::Engine.new(File.read(template)).render(locals)
    end

    def render_xml(template)
      # locals ignored
      File.read(template)
    end

    def action
      self.class.name.gsub(/^.*::/,'')
    end
  end

end