# encoding: utf-8
module Sirena
  module Response
    class Booking < Sirena::Response::Base

      attr_accessor :pnr_number, :timelimit, :status, :lead_family

      def initialize(*)
        super
        @pnr_number = xpath("//pnr/regnum").first
        if @pnr_number
          @pnr_number=@pnr_number.text
        else
          book = xpath("//booking").first.attribute("regnum")
          @pnr_number = book.value if book
        end

        @timelimit = xpath("//pnr/timelimit").first
        @timelimit = Time.parse(@timelimit.text.insert(6, "20")) if @timelimit

        @status = xpath("//pnr/status").first
        @status = @status.text if @status

        xpath("//pnr/passengers/passenger").each do |passanger|
          if passanger.attribute("lead_pass") || @lead_family.blank?
            @lead_family = passanger.xpath('surname').first
            @lead_family = @lead_family.text if @lead_family
          end
        end
      end
    end
  end
end