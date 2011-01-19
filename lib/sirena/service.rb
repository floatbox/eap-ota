# -*- encoding: utf-8 -*-
require 'ostruct'
module Sirena

  class Service

    HOST = 'eviterra.com'#"127.0.0.1"
    PORT = 8888
    PATH = "/"

    class << self

      include FileLogger
      def debug_dir; 'log/sirena' end

      def action(name, params)
        file = File.expand_path("../templates/#{name}.haml", __FILE__)
        if File.file? file
          params = convert_params(params) if params.is_a?(PricerForm)
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
            "Sirena::Response::#{name.camelize}".constantize.response(doc)
          end
        end
      end

      # это должно быть не здесь, подумаю об этом позже
      def convert_params(form)
        params = {:passengers=>[], :segments=>[]}
        if form.people_count[:adults] > 0
          params[:passengers] << {:code=>"ААА", :count=>form.people_count[:adults]}
        end
        # я не знаю, откуда брать возраст в реальной жизни,
        # но он - необходимый параметр, поэтому от балды пока
        if form.people_count[:children] > 0
          params[:passengers] << {:code=>"CHILD", :count=>form.people_count[:children], :age=>10}
        end
        if form.people_count[:infants] > 0
          params[:passengers] << {:code=>"INFANT", :count=>form.people_count[:infants], :age=>1}
        end

        form.form_segments.each{|fs|
          params[:segments] << {:departure=>fs.from_iata, :arrival=>fs.to_iata, 
            :date=>fs.date.insert(2, ".").insert(5, ".20"), :baseclass=>"Э"}
        }

        params
      end
    end

  end

end
