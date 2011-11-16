# encoding: utf-8

class RamblerApi
  include KeyValueInit
  cattr_accessor :search, :recommendation

  def initialize params
    date1 = PricerForm.convert_api_date(params[:request][:dir])
    date2 = PricerForm.convert_api_date(params[:request][:ret])
    pricer_form_hash = {
        :from => params[:request][:src],
        :to => params[:request][:dst],
        :date1 => date1,
        :date2 => date2,
        :adults => params[:request][:adt].to_i,
        :children => params[:request][:cnn].to_i,
        :infants => params[:request][:inf].to_i,
        :cabin => convert_cabin_char(params[:request][:cls]),
        :partner => 'rambler'
    }
    self.search = PricerForm.simple(pricer_form_hash)
    received_segments = params[:response][:dir] + (params[:response][:ret] || [])
    segments = received_segments.collect do |segment|
      Segment.new(:flights =>
        [Flight.new(
          :operating_carrier_iata => segment[:oa],
          :marketing_carrier_iata => segment[:ma],
          :flight_number => segment[:n],
          :departure_iata => params[:request][:src],
          :arrival_iata => params[:request][:dst],
          :departure_date => date1 )])
      end
    variants = Variant.new(:segments => segments)

    booking_classes, cabins =  [], []
    booking_classes, cabins = received_segments.each do |segment|
      booking_classes << segment[:bcl]
      cabins << convert_cabin_char(segment[:cls])
      break booking_classes, cabins
    end

    recommendation = Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => params[:response][:va],
      :booking_classes => booking_classes,
      :cabins => cabins,
      :variants => [variants]
    )
    self.recommendation = recommendation.serialize
  end

  def convert_cabin_char received_cabin
    if received_cabin == 'P'|| received_cabin == 'B'
      'C'
    elsif received_cabin == 'E' || received_cabin == 'A'
      'Y'
    end
  end
end