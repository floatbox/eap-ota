# encoding: utf-8
module Amadeus
  module Response
    class TicketDisplayTST < Amadeus::Response::Base

      include BaggageInfo

      def money_with_refs
        result = {}
        xpath('//r:fareList').each do |fare_node|

          # исходим из того, что "712" (fare, tax and fees) всегда выводится в валюте офиса продажи
          # эквивалентная цена ("E") выдается только в том случае, если валюта "B" отличается от "712"
          # в маске присутствует еще и "TFT", который только fare and tax, но у нас он всегда совпадает с "712"
          fi = fare_node.xpath('r:fareDataInformation')
          total_money = parse_money_element( fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"]') )
          fare_money = parse_money_element(
            fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"]').presence ||
            fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"]')
          )
          tax_money = total_money - fare_money
          fare_details = {:price_fare => fare_money, :price_fare_base => fare_money, :price_tax => tax_money}

          infant_flag = fare_node.xpath('r:statusInformation/r:firstStatusDetails[r:tstFlag="INF"]').present?
          passenger_refs =
            fare_node.xpath(
              'r:paxSegReference/r:refDetails[r:refQualifier="PT" or r:refQualifier="P" or r:refQualifier="PA" or r:refQualifier="PI"]/r:refNumber'
            ).map { |ref_number| [ ref_number.to_i, (infant_flag ? 'i' : 'a') ] }

          segment_refs = fare_node.xpath('r:segmentInformation[r:segDetails/r:ticketingStatus!="NO"]/r:segmentReference/r:refDetails[r:refQualifier="S"]/r:refNumber').every.to_i.sort

          passenger_refs.each do |passenger_ref|
            result[[passenger_ref, segment_refs]] = fare_details
          end

        end
        result
      end

      def total_fare_money
        money_with_refs.values.every[:price_fare].sum
      end

      def total_tax_money
        money_with_refs.values.every[:price_tax].sum
      end

      # временный метод для обеспечения совместимости c текущим кодом
      def prices_with_refs
        Hash[ money_with_refs.map { |refs, money_prices|
            [refs, drop_currency(money_prices)]
        } ]
      end

      def drop_currency money_prices
        Hash[ money_prices.map { |type, money|
          unless money.currency_as_string == "RUB"
            raise "used legacy #prices_with_refs on unsupported currency '#{money.currency_as_string}'"
          end
          [type, money.to_f.to_i]
        } ]
      end

      def total_fare
        prices_with_refs.values.every[:price_fare].sum
      end

      def total_tax
        prices_with_refs.values.every[:price_tax].sum
      end

      def validating_carrier_code
        xpath('//r:carrierCode').to_s
      end

      # нужен LT. есть еще CRD - дата созания маски(?), LMD - дата модификации
      def last_tkt_date
        parse_date_element(xpath('//r:lastTktDate[r:businessSemantic="LT"]/r:dateTime'))
      end

      # количество бланков
      def blank_count
        xpath('//r:fareList/r:paxSegReference/r:refDetails[r:refQualifier="PT" or r:refQualifier="P" or r:refQualifier="PA" or r:refQualifier="PI"]').size
      end

      def error_message
        xpath('//r:applicationError/r:errorText/r:errorFreeText').to_s
      end

      private

      def parse_money_element(node)
        amount = node.xpath('r:fareAmount').to_f
        currency = node.xpath('r:fareCurrency').to_s
        amount.to_money(currency)
      end

    end
  end
end

