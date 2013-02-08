# encoding: utf-8
module PricerFormHelper

  def search_details search
    return {} unless search.valid?
    result = {}
    people = []
    people << t('results.header.adults')[search.adults - 2] if search.adults > 1
    people << t('results.header.children.one') if search.children == 1
    people << t('results.header.children.few', :with => t('results.header.with')[search.children - 2]) if search.children > 1
    people << t('results.header.infants.one') if search.infants == 1
    people << t('results.header.infants.few', :with => t('results.header.with')[search.infants - 2]) if search.infants > 1
    human = [people.join(' '), t(search.cabin, :scope => 'results.header.cabin')]
    human.delete('');
    result[:options] = {
      :adults => search.adults,
      :children => search.children,
      :infants => search.infants,
      :total => search.adults + search.children + search.infants,
      :cabin => search.cabin,
      :human => human.join(', ')
    }
    result[:segments] = search.segments.map{|segment|
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
    }
    result[:segments][1][:rt] = true if search.rt
    result
  end
  
end
  