# encoding: utf-8
module Amadeus
  # soap_actions.yml loader
  module SOAPActions

    SOAP_ACTIONS = YAML.load_file(File.expand_path("../soap_actions.yml",  __FILE__))

    def soap_action(action, args = {})
      if args.is_a? Amadeus::Request::Base
        request_object = args
      else
        request_object = Amadeus::Request.for(action).new(args)
      end
      xmldoc = invoke_rendered action,
        :soap_action => SOAP_ACTIONS[action]['soap_action'],
        :r => SOAP_ACTIONS[action]['r'],
        :request => request_object
      Amadeus::Response.for(action).new(xmldoc)
    end


    SOAP_ACTIONS.keys.each do |action|
      # Amadeus::Service.PNR_AddMultiElements etc.
      define_method action do |*args|
        soap_action action, *args
      end

      # Amadeus::Service.pnr_add_multi_elements etc.
      alias_method action.underscore, action
    end
  end
end
