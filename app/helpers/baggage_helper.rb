# encoding: utf-8
module BaggageHelper
  def baggage_summary(baggage_limitations, lang)
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
      "#{bl.units}&nbsp;#{bl.units > 1 ? 'bag' : 'bags'}".html_safe
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
      "#{bl.units}&nbsp;#{bl.units > 1 ? 'bag' : 'bags'} per&nbsp;passenger".html_safe
    elsif bl.kilos
      "#{bl.kilos}&nbsp;kg per&nbsp;passenger".html_safe
    elsif bl.pounds
      "#{bl.pounds}&nbsp;lb per&nbsp;passenger".html_safe
    else
      ''
    end
  end
end
