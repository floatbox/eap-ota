module Amadeus
  module Response
    class PNRRetrieve < Amadeus::Response::Base

      def flights
        xpath("//r:itineraryInfo").map do |fi|
            Flight.new(
              :operating_carrier_iata => fi.xpath("r:travelProduct/r:companyDetail/r:identification").to_s,
              :departure_iata =>         fi.xpath("r:travelProduct/r:boardpointDetail/r:cityCode").to_s,
              :arrival_iata =>           fi.xpath("r:travelProduct/r:offpointDetail/r:cityCode").to_s,
              :flight_number =>          fi.xpath("r:travelProduct/r:productDetails/r:identification").to_s,
              :arrival_date =>           fi.xpath("r:travelProduct/r:product/r:arrDate").to_s,
              :arrival_time =>           fi.xpath("r:travelProduct/r:product/r:arrTime").to_s,
              :departure_date =>         fi.xpath("r:travelProduct/r:product/r:depDate").to_s,
              :departure_time =>         fi.xpath("r:travelProduct/r:product/r:depTime").to_s,
              :class_of_service =>       fi.xpath("r:travelProduct/r:productDetails/r:classOfService").to_s,
              :equipment_type_iata =>    fi.xpath("r:flightDetail/r:productDetails/r:equipment").to_s,
              :departure_term =>         fi.xpath("r:flightDetail/r:departureInformation/r:departTerminal").to_s,
              :warning =>                fi.xpath("r:errorInfo/r:errorfreeFormText/r:text").to_s
            )
        end
      end

      def passengers
        xpath('//r:travellerInformation').map do |ti|
          Person.new(:first_name => (ti / 'r:passenger/r:firstName').to_s,
                     :last_name => (ti / 'r:traveller/r:surname').to_s)
        end
      end

      def email
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P02"]/r:longFreetext').to_s
      end

      def phone
        xpath('//r:otherDataFreetext[r:freetextDetail/r:type=3]/r:longFreetext').to_s
      end

      def ticket_number
        # PAX 257-9748002002/ETOS/RUB9880/30SEP10/MOWR2290Q/00000000
        fa = xpath('//r:otherDataFreetext[r:freetextDetail/r:type="P06"]/r:longFreetext').to_s
        return unless fa
        fa =~ %r|PAX ([^/]*)|
        $1
      end

      # не используется. но может пригодится еще
      def prices
        code_to_text = {'712' => 'Total fare amount', 'B' => 'Base fare', 'E' => 'Equivalent fare'}
        xpath('//r:fareDataSupInformation').map do |price|
          OpenStruct.new(
            :fareDataQualifier => code_to_text[price.xpath("r:fareDataQualifier").to_s],
            :fareAmount => price.xpath("r:fareAmount").to_s,
            :fareCurrency => price.xpath("r:fareCurrency").to_s
          )
        end
      end

      # не используется. но может пригодится еще
      def taxes
        xpath('//r:taxInformation').map do |tax|
          OpenStruct.new(
            :taxQualifier => tax.xpath("r:taxDetails/r:taxQualifier").to_s,
            :taxIdentifier => tax.xpath("r:taxDetails/r:taxIdentification/r:taxIdentifier").to_s,
            :isoCountry => tax.xpath("r:taxDetails/r:taxType/r:isoCountry").to_s,
            :taxNature => tax.xpath("r:taxDetails/r:taxNature").to_s,
            :fareAmount => tax.xpath("r:amountDetails/r:fareDataMainInformation/r:fareAmount").to_s,
            :fareCurrency => tax.xpath("r:amountDetails/r:fareDataMainInformation/r:fareCurrency").to_s
          )
        end
      end

    end
  end
end
