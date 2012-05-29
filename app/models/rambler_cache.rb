require 'yajl'
require 'httparty'

class RamblerCache
  CABINS_MAPPING = {'M' => 'E', 'W' => 'E', 'Y' => 'E', 'C' => 'B', 'F' => 'F', '' => 'A'}
  # на продакшне хранится в capped collection
  # таблицу надо создавать явно:
  # db.createCollection("rambler_caches", {capped:true, size:200000000})
  # удалять объекты нельзя. обновлять можно только, если не увеличивается размер документа
  # TODO сделать флажок об отправке, заранее сохраненный
  include Mongoid::Document
  include Mongoid::Timestamps
  field :data, :type => Array
  field :pricer_form_hash, :type => Hash

  def self.create_from_form_and_recs(form, recommendations)
    if form.adults == 1 && form.children == 0 && form.infants == 0
      data = recommendations.each_with_object([]) do |rec, res|
        res.concat(rec.variants.map { |v| variant_hash(v, rec, form)})
      end
      res = self.new(:data => data, :pricer_form_hash => form.hash_for_rambler)
      res.save
      res
    end
  end

  def self.variant_hash(variant, recommendation, form)
    people_count = form.people_count
    hash = RamblerApi.recommendation_hash(recommendation, variant)
    uri = RamblerApi.uri_for_rambler(hash)
    res = {
      'va' => recommendation.validating_carrier_iata,
      'c'  => recommendation.price_with_payment_commission,
      'c0' => recommendation.price_with_payment_commission / people_count[:adults],
      'dir' => segment_hash(variant.segments[0]),
      'ret' => variant.segments[1] ? segment_hash(variant.segments[1]) : [],
      'uri' => uri
    }
    [(res['dir'] + res['ret']), recommendation.cabins].transpose.each do |segment_hash, cabin|
      segment_hash['cls'] = CABINS_MAPPING[cabin]
    end
    res
  end

  def self.segment_hash(s)
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

  def self.corrected_date(amadeus_date, amadeus_time)
    m = amadeus_date.match(/(\d{2})(\d{2})(\d{2})/)
    amadeus_time = '0' + amadeus_time if amadeus_time.length == 3
    "20#{m[3]}-#{m[2]}-#{m[1]} #{amadeus_time[0..1]}:#{amadeus_time[2..3]}:00"
  end


end
