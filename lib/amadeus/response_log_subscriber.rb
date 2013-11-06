require 'amadeus'
module Amadeus
  # сохраняет xml ответов амадеуса в log/amadeus/*.
  # TODO может, научить сохранять вместе с текстом запроса?
  class ResponseLogSubscriber < ActiveSupport::LogSubscriber

    def request(event)
      request = event.payload[:request]
      action = request.action
      xml_response = event.payload[:xml_response]
      return unless xml_response
      return if action =~ /Pricer|Security/
      logged_file = log_file(action, xml_response.to_xml)
      # debug "saved to #{logged_file}"
    end

    private

    def debug_dir; 'log/amadeus/'; end

    def log_file(prefix, content)
      path = Rails.root + debug_dir + Time.now.strftime("%Y-%m-%d/")
      base_name = prefix + '.' + Time.now.strftime("%H-%M-%S-%3N") + '.xml'
      name = path + base_name
      FileUtils.mkdir_p(path) unless File.directory?(path)
      File.write(name, content)
      name
    end

    attach_to :amadeus
  end
end
