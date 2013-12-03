# encoding: utf-8
module BaggageHelper
  def baggage_summary(baggage_limitations, lang = nil)
    return unless baggage_limitations
    return if baggage_limitations.any?(&:unknown?) || baggage_limitations.blank?
    return (lang ? 'hand luggage only' : 'только ручная кладь') if baggage_limitations.all?(&:no_baggage?)

    baggage_limitations.find_all{|v| !v.no_baggage?}.group_by do |bl|
      bl.signature
    end.values.partition{|v| v[0].units?}.flatten(1).map do |bl_array|
      c = bl_array.length
      bl = bl_array[0]
      ((c > 1 ? c.to_s + ' x ' : '') + (lang ? baggage_html_en(bl) : baggage_html(bl))).html_safe
    end.join(' +<br>').html_safe
  end

  def baggage_summary_extended(baggage_limitations)
    return unless baggage_limitations
    return if baggage_limitations.any?(&:unknown?) || baggage_limitations.blank?
    return 'только ручная кладь' if baggage_limitations.all?(&:no_baggage?)
    parts = baggage_limitations.find_all{|v| !v.no_baggage?}.group_by do |bl|
      bl.signature
    end.values.partition{|v| v[0].units?}.flatten(1).map do |bl_array|
      bl = bl_array[0]
      unless bl.no_baggage?
        (bl_array.length > 1 ? "#{ bl_array.length } &times; " : '') + baggage_html(bl) + ' на пассажира'
      end
    end
    parts << 'ручная кладь'
    parts.compact.join(' + ').html_safe
  end

  def group_baggage_summaries(baggage_array, flights)
    summaries = baggage_array.map{|bl| baggage_summary_extended(bl) }
    return if summaries.any?(&:nil?)
    if summaries.uniq.length == 1
      ['Норма провоза багажа — ' + summaries[0]]
    else
      flights.map do |f|
        "#{ f.marketing_carrier_iata }&nbsp;#{ f.flight_number }".html_safe
      end.zip(summaries).group_by do |bl|
        bl[1]
      end.values.map do |bl_group|
        'Норма провоза багажа на ' + (bl_group.length == 1 ? 'рейсе ' : 'рейсах ') + bl_group.map(&:first).to_sentence.html_safe + ' — ' + bl_group[0][1]
      end
    end
  end

  def baggage_html(bl)
    return unless bl
    if bl.no_baggage?
      'только ручная кладь'
    elsif bl.units
      "#{bl.units}&nbsp;#{Russian.pluralize(bl.units, 'место', 'места', 'мест')}".html_safe
    elsif bl.kilos
      "#{bl.kilos}&nbsp;кг".html_safe
    elsif bl.pounds
      "#{bl.pounds}&nbsp;lb".html_safe
    else
      ''
    end
  end

  def baggage_html_en(bl)
    return unless bl
    if bl.no_baggage?
      'hand luggage only'
    elsif bl.units
      "#{bl.units}&nbsp;#{bl.units > 1 ? 'bags' : 'bag'}".html_safe
    elsif bl.kilos
      "#{bl.kilos}&nbsp;kg".html_safe
    elsif bl.pounds
      "#{bl.pounds}&nbsp;lb".html_safe
    else
      ''
    end
  end

  def baggage_html_simple(bl)
    return unless bl
    if bl.no_baggage?
      'только ручная кладь'
    elsif bl.units
      "#{bl.units}&nbsp;#{Russian.pluralize(bl.units, 'место', 'места', 'мест')} на&nbsp;пассажира".html_safe
    elsif bl.kilos
      "#{bl.kilos}&nbsp;кг на&nbsp;пассажира".html_safe
    elsif bl.pounds
      "#{bl.pounds}&nbsp;lb на&nbsp;пассажира".html_safe
    else
      ''
    end
  end
  
  def baggage_html_simple_en(bl)
    return unless bl
    if bl.no_baggage?
      'hand luggage only'
    elsif bl.units
      "#{bl.units}&nbsp;#{bl.units > 1 ? 'bags' : 'bag'} per&nbsp;passenger".html_safe
    elsif bl.kilos
      "#{bl.kilos}&nbsp;kg per&nbsp;passenger".html_safe
    elsif bl.pounds
      "#{bl.pounds}&nbsp;lb per&nbsp;passenger".html_safe
    else
      ''
    end
  end
end
