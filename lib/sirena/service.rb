# -*- encoding: utf-8 -*-
module Sirena

  class Service

    HOST = 'eviterra.com'#"127.0.0.1"
    PORT = 8888
    PATH = "/"

    PARAMETERS = {:schedule=>%w(departure arrival company date date2 time_from time_till direct)}

    class << self

      include FileLogger
      def debug_dir; 'log/sirena' end

      def action(name, params)
        file = File.expand_path("../templates/#{name}.haml", __FILE__)
        if File.file? file
           request = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+Haml::Engine.new(File.read(file)).render(OpenStruct.new(params))
           print request+"\n\n"
           http= Net::HTTP.new(HOST, PORT)
           parse_response(name, http.post(PATH, request))
        else
          puts "unknown action #{name}"
        end
      end

      def parse_response(name, http_response)
        if http_response.code != '200'
          puts http_response.code+": \n\n"+http_response.body
        else
          save_xml(name, http_response.body)
          doc = Nokogiri::XML::Document.parse(http_response.body)
          error = doc.xpath('//error')
          unless error.blank?
            puts error.inner_html
          else
            info = doc.xpath('//info')
            print info.inner_html unless info.blank?
            doc.xpath("//#{name}")
          end
        end
      end
    end

  end

end
