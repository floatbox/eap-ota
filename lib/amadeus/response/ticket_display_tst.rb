# encoding: utf-8
module Amadeus
  module Response
    class TicketDisplayTST < Amadeus::Response::Base

      include BaggageInfo

      # Всякие дебажные методы

      # по всей видимости, (1 валюты "B") / (1 валюты "712" или "E")
      # nil, если нет конверсии
      # но тариф явно округляется при конверсии, в отличие от общей суммы
      def bank_rate
        xpath('//r:bankerRates/r:firstRateDetail/r:amount').to_f
      end

      def carrier_currency_code
        xpath('//r:fareDataSupInformation[r:fareDataQualifier="B"]/r:fareCurrency').to_s
      end

      def bank_exchange
        from = xpath('//r:fareDataSupInformation[r:fareDataQualifier="B"]/r:fareCurrency').to_s
        to = xpath('//r:fareDataSupInformation[r:fareDataQualifier="E"]/r:fareCurrency').to_s
        bank = Money::Bank::VariableExchange.new
        if to && bank_rate
          bank.add_rate(from, to, bank_rate)
          bank.add_rate(to, from, 1/bank_rate)
        end
        bank
      end

      def point_of_sale_office
        xpath('//r:contextualPointofSale/r:originIdentification/r:inHouseIdentification2').to_s
      end

      # Остальные, более полезные методы

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
          fare_details = {
            :original_price_fare => fare_money,
            :original_price_tax => tax_money
          }

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
        money_with_refs.values.every[:original_price_fare].sum
      end

      def total_tax_money
        money_with_refs.values.every[:original_price_tax].sum
      end

      # временный метод для обеспечения совместимости c текущим кодом
      def prices_with_refs
        Hash[ money_with_refs.map { |refs, money_prices|
            [refs, drop_currency(money_prices)]
        } ]
      end

      def drop_currency money_prices
        Hash[ money_prices.map { |type, money|
          [type, (money.is_a?(Money) ? money.to_f.to_i : money ) ]
        } ]
      end

      def total_fare
        prices_with_refs.values.every[:original_price_fare].sum
      end

      def total_tax
        prices_with_refs.values.every[:original_price_tax].sum
      end

      def validating_carrier_code
        xpath('//r:carrierCode').to_s
      end

      def last_tkt_date
        parse_date_element(xpath('//r:lastTktDate[r:businessSemantic="LT"]/r:dateTime'))
      end

      # дата создания маски
      def created_on
        parse_date_element(xpath('//r:lastTktDate[r:businessSemantic="CRD"]/r:dateTime'))
      end

      # дата модификации маски
      def updated_on
        parse_date_element(xpath('//r:lastTktDate[r:businessSemantic="LMD"]/r:dateTime'))
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

