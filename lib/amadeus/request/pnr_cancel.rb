module Amadeus
  module Request
    class PNRCancel  < Amadeus::Request::Base

      # номер PNR. Если не указывать - работает с текущим.
      # Если указать - сделает PNR_Retrieve.
      attr_accessor :number

      # :ER, :ET, :NOP, etc.
      attr_accessor :pnr_action

      # Внимание, опции ниже нельзя указывать одновременно!

      # true для отмены всего маршрута (XI)
      attr_accessor :itinerary

      # (XE) Важно: это не номера строк в терминальном PNR, а tattoo из PNR_Reply

      # один или несколько reference[qualifier=='OT']/number
      attr_accessor :element

      # один или несколько reference[qualifier=='ST']/number
      attr_accessor :segment

      # один или несколько reference[qualifier=='PT']/number
      attr_accessor :passenger

      def initialize(*)
        super
      end

      # варианты кодов для #pnr_action
      ACTION_CODES = {
        :NOP => 0,
        :ET => 10,
        :ER => 11,
        :IG => 20,
        :LINES => 52
      }.freeze

      def option_codes
        pnr_actions = Array.wrap(@pnr_action).presence || [:NOP]
        pnr_actions.map { |code| ACTION_CODES.fetch(code) }
      end

      def summary
        [ number,
          (itinerary && 'itinerary'),
          (element && 'element'),
          (segment && 'segment'),
          (passenger && 'passenger'),
          element, segment, passenger,
          pnr_action,
        ].flatten.compact.join(' ')
      end

    end
  end
end

