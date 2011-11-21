require 'yajl'
require 'httparty'

class RamblerCache
  CABINS_MAPPING = {'Y' => 'E', 'C' => 'B', 'F' => 'F', '' => 'A'}
  # на продакшне хранится в capped collection
  # таблицу надо создавать явно:
  # db.createCollection("rambler_caches", {capped:true, size:200000000})
  # удалять объекты нельзя. обновлять можно только, если не увеличивается размер документа
  # TODO сделать флажок об отправке, заранее сохраненный
  include Mongoid::Document
  include Mongoid::Timestamps
  field :data, :type => Array
  field :sent_to_rambler, :type => Boolean, :default => false
  belongs_to :pricer_form

  def self.send_to_rambler(count = 100)
    data_to_send = self.where(:sent_to_rambler => false).order_by([:created_at, :asc]).limit(count).to_a
    if data_to_send.count > 0
      json_string = Yajl::Encoder.encode(data_to_send.map{|rc| {:request => rc.pricer_form_hash , :variants => rc.data}   })
      data_to_send.every.update_attribute(:sent_to_rambler, true)
      response = HTTParty.post(Conf.api.rambler_url, :body => json_string, :format => :json)
      Rails.logger.info "Rambler api: request with #{data_to_send.count} searches sent"
    end
  end

  def pricer_form_hash
    return if pricer_form.complex_route?
    res = {
      :src => pricer_form.segments[0].from_iata,
      :dst => pricer_form.segments[0].to_iata,
      :dir => pricer_form.segments[0].date_as_date.strftime('%Y-%m-%d'),
      :cls => CABINS_MAPPING[pricer_form.cabin],
      :adt => pricer_form.adults,
      :cnn => pricer_form.children,
      :inf => pricer_form.infants,
      :wtf => 0
    }
    res.merge({:ret => pricer_form.segments[1].date_as_date.strftime('%Y-%m-%d')}) if pricer_form.segments[1]
    res
  end

  def self.from_form_and_recs(form, recommendations)
    data = recommendations.each_with_object([]) do |rec, res|
      res.concat(rec.variants.map { |v| variant_hash(v, rec, form.people_count)})
    end
    self.new(:data => data, :pricer_form => form)
  end

  def self.variant_hash(variant, recommendation, people_count = {:adults => 1})
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
