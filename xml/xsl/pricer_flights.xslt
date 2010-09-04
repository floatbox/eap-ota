<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

                xmlns:r="http://xml.amadeus.com/FMPTBR_09_1_1A"
                exclude-result-prefixes="r"
                >
<xsl:output indent="yes" />
<xsl:template match="text()" />
<!-- возвращает неконформный xml документ - несколько roots. "лес" -->

<xsl:template match="r:flightIndex">
  <requested_segment>
    <xsl:apply-templates select="r:groupOfFlights" />
  </requested_segment>
</xsl:template>

<xsl:template match="r:groupOfFlights">
  <segment>
    <xsl:apply-templates select="r:flightDetails/r:flightInformation" />
  </segment>
</xsl:template>

<xsl:template match="r:flightInformation">
   <flight
      operating_carrier_iata="{r:companyId/r:operatingCarrier}"
      marketing_carrier_iata="{r:companyId/r:marketingCarrier}"
      departure_iata="{r:location[1]/r:locationId}"
      departure_term="{r:location[1]/r:terminal}"
      arrival_iata="{r:location[2]/r:locationId}"
      arrival_term="{r:location[2]/r:terminal}"
      flight_number="{r:flightNumber}"
      arrival_date="{r:productDateTime/r:dateOfArrival}"
      arrival_time="{r:productDateTime/r:timeOfArrival}"
      departure_date="{r:productDateTime/r:dateOfDeparture}"
      departure_time="{r:productDateTime/r:timeOfDeparture}"
      equipment_type_iata="{r:productDetail/r:equipmentType}"
    />
</xsl:template>

</xsl:stylesheet>
