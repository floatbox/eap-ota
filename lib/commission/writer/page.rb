# encoding: utf-8
class Commission::Writer::Page

  def initialize(page)
    @page = page
  end

  def write
    str = ""
    str << %[carrier #{@page.carrier.inspect}]
    @page.ticketing_method and
      str << %[, ticketing_method: #{@page.ticketing_method.to_s.inspect}]
    @page.start_date and
      str << %[, start_date: #{@page.start_date.to_s.inspect}]
    @page.no_commission and
      str << %[, no_commission: #{@page.no_commission.to_s.inspect}]
    str << "\n\n"

    @page.rules.each do |rule|
      str << Commission::Writer::Rule.new(rule).write
      str << "\n"
    end

    str
  end

end
