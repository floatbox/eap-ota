# encoding: utf-8
module Admin::OurTypesHelper

  # decimal у нас сейчас почти исключительно для сумм в рублях. потом что-то другое придумаем
  def display_decimal(item, attribute)
    val = item.send(attribute)
    # ломается на Float
    #if val.frac.zero?
    #  "%.f р." % val
    #else
    #  "%.2f р." % val
    #end
    # грубо, но должно работать
    ("%.2f р." % val).sub(/\.00/, '')
  end

  def table_decimal_field(attribute, item)
    "<div style='text-align:right;'>#{ (raw_content = item.send(attribute)).present? ? ('%.2f' % raw_content) : mdash }</div>".html_safe
  end

end
