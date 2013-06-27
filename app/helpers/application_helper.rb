# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def geo_tags_for location
    location.geo_tags.collect do |geo_tag|
      link_to h(geo_tag.name), geo_tag
    end.join ' '
  end

  def cases_for location
    "лечу #{location.case_from} #{location.case_to} c пересадкой #{location.case_in}"
  end

  def ordinal number
    return "#{number}й" unless (1..9) === number.to_i
    %w{первый второй третий четвертый пятый шестой седьмой восьмой девятый}[number - 1]
  end

  def nbsp string
    html_escape(string).gsub(/ +/, '&nbsp;').html_safe
  end

  def profile_confirm_url(options = nil)
    root_url(:anchor => options.to_query)
  end

  #для тайпуса
  def display_date item, attribute
    item.send(attribute).strftime("%d %b %Y")
  end

  def display_virtual *attrs
    display_string *attrs
  end

  def display_price price
    number_to_currency(price, :delimiter => " ", :separator => ",", :precision => 0, :locale => :ru)
  end

  def display_percent persent
    number_to_percentage(persent, :delimiter => " ", :separator => ",", :precision => 2, :locale => :ru)
  end

  def display_numbers number
    number_with_delimiter(number.to_i, :delimiter => " ", :separator => ",", :precision => 0, :locale => :ru)
  end

  def exact_price(price)
    sprintf("%.2f", price).sub('.', ',')
  end

  def display_rt_arrow rt
    Destination.rts.invert[rt]
  end
end

