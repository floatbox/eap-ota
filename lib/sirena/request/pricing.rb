# encoding: utf-8
module Sirena
  module Request
    class Pricing < Sirena::Request::Base
      attr_accessor :passengers, :segments
      # это должно быть здесь, я уже всеоо придумал
      def initialize(form)
        @passengers = []
        if form.people_count[:adults] > 0
          @passengers << {:code => "ААА", :count => form.people_count[:adults]}
        end
        # я не знаю, откуда брать возраст в реальной жизни,
        # но он - необходимый параметр, поэтому от балды пока
        if form.people_count[:children] > 0
          @passengers << {:code=>"CHILD", :count => form.people_count[:children], :age => 10}
        end
        if form.people_count[:infants] > 0
          @passengers << {:code=>"INFANT", :count => form.people_count[:infants], :age => 1 }
        end

        @segments = form.form_segments.collect { |fs|
          { :departure => fs.from_iata,
            :arrival => fs.to_iata,
            :date => sirena_date(fs.date),
            :baseclass => "Э"
          }
        }
      end

    end
  end
end
