module Amadeus
  module Request

    # A PNR must contain the following five elements:
    #
    # Name element
    # A passenger name.
    #
    # Itinerary element
    # A booking for a flight or other service.
    #
    # Contact element
    # Telephone number or contact information for the person making the booking.
    #
    # Ticketing element
    # A indication of the arrangements for issuing a ticket for the booking.
    #
    # Received from element
    class PNRAddMultiElements < Amadeus::Request::Base

      include CopyAttrs

      # варианты кодов для #pnr_action
      ACTION_CODES = {
        :NOP => 0,
        # сохранить и закрыть PNR.
        :ET => 10,
        # сохранить и оставить PNR открытым.
        :ER => 11,
        # разные варианты сохранения с ознакомлением о изменении статусов отдельных сегментов.
        :ETK => 12, :ERK => 13, :EF => 14, :ETX => 15, :ERX => 16,
        # игнорировать изменения и закрыть PNR.
        :IG => 20,
        # игнорировать изменения и оставить PNR открытым.
        :IR => 21,
        # :SHORT  - ошибка для ET IR, никакого эффекта для ER, IG, остальные не разбирал.
        :STOP => 267, :WARNINGS => 30, :SHORT => 50
      }.freeze

      # Коды для управления транзакцией PNR. один (или несколько!) из ACTION_CODES
      attr_accessor :pnr_action

      # email клиента.
      attr_accessor :email

      # Телефон клиента.
      attr_accessor :phone

      # Пассажиры (все и по категориям)
      attr_accessor :people
      attr_accessor :adults
      attr_accessor :children
      attr_accessor :infants
      # Hash с ключами :adults, :infants, :children.
      # @todo избавиться от параметра, мы уже передаем всех пассажиров.
      attr_accessor :people_count

      # Валидирующий перевозчик. Используется еще и в некоторых SSR-ремарках.
      # (FV...)
      attr_accessor :validating_carrier

      # Commission::Formula проставляемой агентской комиссии.
      # (FM...)
      attr_accessor :agent_commission

      # DateTime времени для отмены бронирования.
      # @todo уточнить таймзону. Документация амадеуса говорит, что tk_xl выставляется в локальном времени (по Москве?)
      attr_accessor :tk_xl

      # "Референция агента", без нее не должно работать сохранение изменений. Однако работает в наших основных офисах.
      # Лучше будем вносить явно.
      # (RF)
      attr_accessor :received_from

      # Офис для копии AIR-файла
      # FIXME не работает почему-то
      # (FK MOWR228FA)
      attr_accessor :fk

      # Офисы для выдачи полного доступа к PNR.
      # (ES...-B)
      attr_accessor :full_access

      # Способ платежа, сейчас это только наличка.
      # (FP CASH)
      attr_accessor :form_of_payment

      # Наш телефон.
      # (AP и OSYYCTCP)
      attr_accessor :our_contacts

      # Ремарки.
      attr_accessor :remarks

      # Сохранять PNR в базе амадеуса даже после отлета. (максимум - год)
      # (RU...)
      attr_accessor :archive

      # Внесение полетных сегментов. Сейчас не используется.
      attr_accessor :recommendation

      def initialize(*)
        # defaults
        # ...
        super
      end

      def option_codes
        pnr_actions = Array.wrap(@pnr_action).presence || [:NOP]
        pnr_actions.map { |code| ACTION_CODES.fetch(code) }
      end

      def tk_xl_date
        tk_xl.strftime("%d%m%y")
      end

      def tk_xl_time
        tk_xl.strftime("%H%M")
      end

      def archive_date
        (Date.today + 10.months).strftime("%d%m%y")
      end

      def seat_total
        people_count[:adults] + people_count[:children]
      end

      def ssr_docs_text(person)
        [
          "P",
          person.nationality.alpha3,
          person.cleared_passport,
          person.nationality.alpha3,
          person.birthday.strftime('%d%b%y').upcase,
          person.sex.upcase + (person.infant ? 'I' : ''),
          person.smart_document_expiration_date.strftime('%d%b%y').upcase,
          person.last_name,
          person.first_name,
          "H"
        ].map(&:to_s).join('-')
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
        agent_commission.apply.round
      end

      # подавление ошибки
      # SRFOID error: XX: INVALID REQUEST FOR ELEMENT
      # FIXME а можно ли SRFOID делать на YY и игнорировать подобные warning-и?
      def srfoid_needed?
        %W[AB UN HR B2 PS AZ CY LX KK OS KM SQ F7 ET 9W PG CI SW MU FJ WY].exclude? validating_carrier
      end

      # подставляет дефолтную референцию, если received_from: true
      def rf_value
        (received_from == true)? 'WS' : received_from
      end

      def summary
        pnr_action.to_s if pnr_action && pnr_action != :NOP
      end
    end
  end
end

