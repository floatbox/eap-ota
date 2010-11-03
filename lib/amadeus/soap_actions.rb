module Amadeus
  # soap_actions.yml loader
  module SOAPActions

    SOAP_ACTIONS = YAML.load_file(File.expand_path("../soap_actions.yml",  __FILE__))

    def soap_action(action, args = nil)
      response = invoke_rendered action,
        :soap_action => SOAP_ACTIONS[action]['soap_action'],
        :r => SOAP_ACTIONS[action]['r'],
        :args => args
    end


    SOAP_ACTIONS.keys.each do |action|
      # Amadeus::Service.PNR_AddMultiElements etc.
      define_method action do |args|
        soap_action action, args
      end

      # Amadeus::Service.pnr_add_multi_elements etc.
      alias_method action.underscore, action
    end
  end
end
