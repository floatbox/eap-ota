# encoding: utf-8

# наколенный JSON-сериализатор.
# ugly as hell, но как похорошел!
class AviaSearchSerializer

  # FIXME он тут и правда используется?
  include TranslationHelper

  attr_accessor :search

  def initialize(search)
    @search = search
  end

  # FIXME пройтись по всем полям и удалить неиспользуемое
  def as_json(*)
    return {} unless search
    if search.valid?
      {
        query_key: search.to_param,
        segments: segments,
        map_segments: map_segments,
        short: human_short,
        options: {
          adults: search.adults,
          children: search.children,
          infants: search.infants,
          total: search.adults + search.children + search.infants,
          cabin: search.cabin,
          human: human
        },
        valid: true
      }
    else
      {
        map_segments: map_segments,
        errors: search.segments.flat_map(&:errors)
      }
    end
  end

  # TranslationHelper#human_people maybe?
  def human
    person_parts = []

    person_parts << %W[
      вдвоем втроем вчетвером впятером вшестером всемером ввосьмером
    ][search.adults-2]  if search.adults > 1

    person_parts << [
      'с&nbsp;ребенком',
      'с&nbsp;двумя детьми',
      'с&nbsp;тремя детьми',
      'с&nbsp;четырьмя детьми',
      'с&nbsp;пятью детьми',
      'с&nbsp;шестью детьми',
      'с&nbsp;семью детьми'
    ][search.children-1] if search.children > 0

    person_parts << 'и' if search.infants > 0 && search.children > 0

    person_parts << [
      'с&nbsp;младенцем',
      'с&nbsp;двумя младенцами',
      'с&nbsp;тремя младенцами',
      'с&nbsp;четырьмя младенцами',
      'с&nbsp;пятью младенцами',
      'с&nbsp;шестью младенцами',
      '7 младенцев'
    ][search.infants-1] if search.infants > 0

    human_parts = []

    human_parts << person_parts.join(' ') unless person_parts.empty?

    case search.cabin
    when 'C'
      human_parts << 'бизнес-классом'
    when 'F'
      human_parts << 'первым классом'
    end

    human_parts.join(', ')
  end

  def segments
    result = search.segments.map do |segment|
      dpt = segment.from
      arv = segment.to
      {
        :title => "#{ dpt.case_from } #{ arv.case_to }",
        :short => "#{ dpt.iata } &rarr; #{ arv.iata }",
        :arvto => "#{ arv.case_to }",
        :arvto_short => "в #{ arv.iata }",
        :date => segment.date_for_render,
        :dpt => {:name => dpt.name},
        :arv => {:name => arv.name},
      }
    end
    result[1][:rt] = true if search.rt
    result
  end

  def human_short
    if search.rt
      "#{search.segments[0].from.name} &harr; #{search.segments[0].to.name}, #{search.segments[0].short_date} — #{search.segments[1].short_date}"
    else
      parts = []
      complex = search.segments.length > 1
      search.segments.each do |segment|
        if complex
          parts << "#{segment.from.iata} &rarr; #{segment.to.iata} #{segment.short_date}"
        else
          parts << "#{segment.from.name} &rarr; #{segment.to.name} #{segment.short_date}"
        end
      end
      parts.join(', ')
    end
  end

  def human_locations
    result = {}
    search.segments.each_with_index do |fs, i|
      if fs.from && fs.to
        result["dpt_#{i}"] = fs.from.case_from
        result["arv_#{i}"] = fs.to.case_to
      end
    end
    result
  end

  def map_segments
    result = search.segments.map{|s|
      {
        :dpt => map_point(s.from),
        :arv => map_point(s.to)
      }
    }
    # piglet piter
    if result.length == 1
      dpt = from
      arv = to
      if dpt && arv
        dpt_alpha2 = dpt.class == Country ? dpt.alpha2 : dpt.country.alpha2
        arv_alpha2 = arv.class == Country ? arv.alpha2 : arv.country.alpha2
        if dpt_alpha2 == 'RU' && (arv_alpha2 == 'US' || arv_alpha2 == 'IL' || arv_alpha2 == 'GB')
          result.first[:leave] = true
        end
      end
    end
    result
  end

  def map_point obj
    obj && {
      :name => obj.name,
      :from => obj.case_from,
      :iata => obj.iata,
      :lat => obj.lat,
      :lng => obj.lng
    }
  end

end

