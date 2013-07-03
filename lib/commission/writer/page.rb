# encoding: utf-8
class Commission::Writer::Page

  def initialize(page)
    @page = page
  end

  def write
    str = ""
    if @page.start_date
      str << %[carrier #{@page.carrier.inspect}, start_date: #{@page.start_date.to_s.inspect}\n]
    else
      str << %[carrier #{@page.carrier.inspect}\n]
    end
    str << "\n"

    @page.all.each do |rule|
      str << Commission::Writer::Rule.new(rule).write
      str << "\n"
    end

    str
  end

end
