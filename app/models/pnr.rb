class Pnr
  attr_accessor :number, :flights, :passengers, :phone, :email, :raw
  
  def self.get_by_number number
    res = self.new
    res.number = number
    amadeus = Amadeus.new(:book => true)
    xml = amadeus.pnr_retrieve(:number => number)
    res.parse_pnr(xml)
    res.raw = amadeus.cmd("RT #{number}")
    amadeus.cmd('IG')
    res
  end
  
  
  def parse_pnr(xml)
    self.flights = xml.xpath("//r:itineraryInfo").map { |fi|
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
    }
    self.passengers = xml.xpath('//r:travellerInformation').map{|ti| Person.new(:first_name => (ti / './r:passenger/r:firstName').to_s, :last_name => (ti / './r:traveller/r:surname').to_s)}
    self.email = xml.xpath('//r:freetextDetail[r:type="P02"]/../r:longFreetext').to_s
    self.phone = xml.xpath('//r:freetextDetail[r:type=3]/../r:longFreetext').to_s
  end

  
  # зачем оно?
  def parse_prices(xml)
    code_to_text = {'712' => 'Total fare amount', 'B' => 'Base fare', 'E' => 'Equivalent fare'}
    self.prices = xml.xpath('//r:fareDataSupInformation').map{|price|
      OpenStruct.new(:fareDataQualifier => code_to_text[price.xpath("r:fareDataQualifier").to_s], :fareAmount => price.xpath("r:fareAmount").to_s, :fareCurrency => price.xpath("r:fareCurrency").to_s)
    }
    self.taxes = xml.xpath('//r:taxInformation').map{|tax|
      OpenStruct.new(:taxQualifier => tax.xpath("r:taxDetails/r:taxQualifier").to_s,
                     :taxIdentifier => tax.xpath("r:taxDetails/r:taxIdentification/r:taxIdentifier").to_s,
                     :isoCountry => tax.xpath("r:taxDetails/r:taxType/r:isoCountry").to_s,
                     :taxNature => tax.xpath("r:taxDetails/r:taxNature").to_s,
                     :fareAmount => tax.xpath("r:amountDetails/r:fareDataMainInformation/r:fareAmount").to_s,
                     :fareCurrency => tax.xpath("r:amountDetails/r:fareDataMainInformation/r:fareCurrency").to_s)
    }
  end
  
end
