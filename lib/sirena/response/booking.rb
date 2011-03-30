# encoding: utf-8
module Sirena
  module Response
    class Booking < Sirena::Response::Base

      attr_accessor :pnr_number, :timelimit, :status, :lead_family

      def parse
        @pnr_number = at_xpath("//pnr/regnum")
        if @pnr_number
          @pnr_number=@pnr_number.text
        else
          book = at_xpath("//booking")
          @pnr_number = book["regnum"] if book
        end

        @timelimit = at_xpath("//pnr/timelimit")
        @timelimit = Time.parse(@timelimit.text.insert(6, "20")) if @timelimit

        @status = xpath("//pnr/status").text

        xpath("//pnr/passengers/passenger").each do |passanger|
          if passanger.attribute("lead_pass") || @lead_family.blank?
            @lead_family = passanger.xpath('surname').text
          end
        end
      end
    end
  end
end
