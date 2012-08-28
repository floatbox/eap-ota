# encoding: utf-8
module Amadeus
  module Response
    class TicketDisplayTST < Amadeus::Response::Base

      include BaggageInfo

      def money_with_refs
        xpath('//r:fareList/r:paxSegReference/r:refDetails[r:refQualifier="PT" or r:refQualifier="P" or r:refQualifier="PA" or r:refQualifier="PI"]').inject({}) do |memo, rd|
          passenger_ref = rd.xpath('r:refNumber').to_i
          infant_flag = rd.xpath('../../r:statusInformation/r:firstStatusDetails[r:tstFlag="INF"]').present?
          segments_refs = rd.xpath('../../r:segmentInformation[r:segDetails/r:ticketingStatus!="NO"]/r:segmentReference/r:refDetails[r:refQualifier="S"]/r:refNumber').every.to_i.sort
          fi = rd.xpath('../../r:fareDataInformation')
          # исходим из того, что "712" (fare, tax and fees) всегда выводится в валюте офиса продажи
          # эквивалентная цена ("E") выдается только в том случае, если валюта "B" отличается от "712"
          # в маске присутствует еще и "TFT", который только fare and tax, но у нас он всегда совпадает с "712"
          total_money = parse_money_element( fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="712"]') )
          fare_money = parse_money_element(
            fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="E"]').presence ||
            fi.xpath('r:fareDataSupInformation[r:fareDataQualifier="B"]')
          )
          tax_money = total_money - fare_money
          memo.merge([[passenger_ref, infant_flag ? 'i' : 'a'], segments_refs] => {:price_fare => fare_money, :price_tax => tax_money, :price_fare_base => fare_money})
        end
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

