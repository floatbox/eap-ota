module RamblerApi
  CABINS_MAPPING = {'Y' => 'E', 'C' => 'B', 'F' => 'F'}

  def rambler_data_from_recs(form, recommendations)
    recommendations.each_with_object([]) do |rec, res|
      res.concat(rec.variants.map { |v| variant_hash(v, rec, form.people_count)})
    end
  end

  def variant_hash(variant, recommendation, people_count = {:adults => 1})
    res = {
      'va' => recommendation.validating_carrier_iata,
      'c'  => recommendation.price_with_payment_commission,
      'c0' => recommendation.price_with_payment_commission / people_count[:adults],
      'dir' => segment_hash(variant.segments[0]),
      'ret' => variant.segments[1] ? segment_hash(variant.segments[1]) : []
    }
    [(res['dir'] + res['ret']), recommendation.cabins, recommendation.booking_classes].transpose.each do |segment_hash, cabin, booking_class|
      segment_hash['cls'] = CABINS_MAPPING[cabin]
      segment_hash['bcl'] = booking_class
    end
    res
  end

  def segment_hash(s)
    s.flights.map do |f|
      {'oa' => f.operating_carrier_iata,
       'ma' => f.marketing_carrier_iata,
       'n' => f.flight_number.to_i,
       'eq' => f.equipment_type_iata,
       'dur' => f.duration,
       'dep' => {
          'p' => f.departure_iata,
          'dt' => corrected_date(f.departure_date, f.departure_time),
          't' => f.departure_term
         },
      'arr' => {
          'p' => f.arrival_iata,
          'dt' => corrected_date(f.arrival_date, f.arrival_time),
          't' => f.arrival_term
         }
      }
    end
  end

  def corrected_date(amadeus_date, amadeus_time)
    m = amadeus_date.match(/(\d{2})(\d{2})(\d{2})/)
    amadeus_time = '0' + amadeus_time if amadeus_time.length == 3
    "20#{m[3]}-#{m[2]}-#{m[1]} #{amadeus_time[0..1]}:#{amadeus_time[2..3]}:00"
  end

end
