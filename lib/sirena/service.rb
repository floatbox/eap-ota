# -*- encoding: utf-8 -*-
module Sirena

  class Service

    Url = 'eviterra.com'#"127.0.0.1"
    Port = 8888
    Path = "/"

    Parameters = {:schedule=>%w(departure arrival company date date2 time_from time_till direct)}

    class << self

      def action(name, params)
        file = File.expand_path("../templates/#{name}.haml", __FILE__)
        if File.file? file
           request = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"+Haml::Engine.new(File.read(file)).render(OpenStruct.new(params))
           print request+"\n\n"
           http= Net::HTTP.new(Url, Port)
           parse_respond(name, http.post(Path, request))
        else
          puts "unknown action #{name}"
        end
      end

      def parse_respond(name, http_request)
        if http_request.code != '200'
          puts http_request.code+": \n\n"+http_request.body
        else
          doc = Nokogiri::XML::Document.parse(http_request.body)
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
