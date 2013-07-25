# encoding: utf-8
module PricerFormHelper

  def search_details search
    return {} unless search.valid?
    result = {}
    human = [human_people(search.adults, search.children, search.infants), t(search.cabin, :scope => 'results.header.cabin', :default => '')]
    human.delete('');
    result[:options] = {
      :adults => search.adults,
      :children => search.children,
      :infants => search.infants,
      :total => search.adults + search.children + search.infants,
      :cabin => search.cabin,
      :human => human.join(', ')
    }
    result[:segments] = search.segments.map do |segment|
      # should call fix_segments before that
      dpt = segment.from_as_object
      arv = segment.to_as_object 
      {
        :title => "#{ dict(dpt, :from) } #{ dict(arv, :to) }",
        :arvto => "#{ dict(arv, :to) }",
        :short => "#{ dpt.iata } &rarr; #{ arv.iata }",
        :arvto_short => "в #{ arv.iata }",
        :date => segment.date,
        :dpt => {:name => dpt.name},
        :arv => {:name => arv.name},
      }
    end
    result[:segments][1][:rt] = true if search.rt
    result
  end
  
end
