# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

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

  def smart_root_path
    site_url = (Conf.site.ssl ? 'https://' : 'http://') + "#{Conf.site.host}/"
    root_url.eql?(site_url) ? '/' : site_url
  end

end

