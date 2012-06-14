module Amadeus
  module Request
    class PNRAddMultiElements < Amadeus::Request::Base

      include CopyAttrs

      attr_accessor :people_count, :email, :phone, :people, :adults, :children, :infants, :validating_carrier, :agent_commission, :tk_xl
      def action_codes
        {:NOP => 0, :ET => 10, :ER => 11, :ETK => 12, :ERK => 13, :EF => 14, :ETX => 15, :ERX => 16, :IG => 20, :IR => 21, :STOP => 267, :WARNINGS => 30, :SHORT => 50}
      end
      attr_accessor :pnr_action
      attr_accessor :recommendation #сейчас не используется

      # может принимать PricerForm
      def initialize(opts)
        # defaults
        @pnr_action = :ER
        # end of defaults
        if opts.is_a? Hash
          super
        else
          copy_attrs opts, self,
            :people_count,
            :email,
            :phone,
            :people,
            :adults,
            :children,
            :infants,
            :validating_carrier,
            :agent_commission,
            :tk_xl
        end
      end

      def tk_xl_date
        tk_xl.strftime("%d%m%y") if tk_xl
      end

      def archive_date
        (Date.today + 10.months).strftime("%d%m%y")
      end

      def seat_total
        people_count[:adults] + people_count[:children]
      end

      def ssr_docs_text(person)
        "P/#{person.nationality.alpha3}/#{person.passport}/#{person.nationality.alpha3}/#{person.birthday.strftime('%d%b%y').upcase}/#{person.sex.upcase}#{person.infant? ? 'I' : ''}/#{person.smart_document_expiration_date.strftime('%d%b%y').upcase}/#{person.last_name}/#{person.first_name}/H"
      end

      def es_office_id
        ::Amadeus::Session::BOOKING
      end

      def tk_xl_time
        tk_xl.strftime("%H%M") if tk_xl
      end

      # не подставляет пустые комиссии
      def agent_commission?
        agent_commission.present?
      end

      def agent_commission_percentage
        agent_commission.percentage? && ("%g" % agent_commission.rate)
      end

      def agent_commission_value
        raise "trying to add percentage or complex formula at FM? (#{agent_commission})" if
          agent_commission.complex? || agent_commission.percentage?
        # рублевая комиссия округляется до ближайшего целого
        # евро подставляются в дефолтных параметрах формулы из конфига (зря?)
        agent_commission.call.round
      end

    end
  end
end

