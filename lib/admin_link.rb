# encoding: utf-8
#
# хелпер для консоли и скриптов, для создания ссылок на админку
# теоретически, можно сделать с помощью url_for, но лень.
module AdminLink
  def admin_link(object)
    base = "https://eviterra.com/admin/"
    case object
    when Order
      base + "orders/show/#{object.id}"
    when Payment
      base + "payments/show/#{object.id}"
    when Commission
      base + "commissions/##{object.carrier}_#{object.number}"
    when Airport
      base + "airports/show/#{object.id}"
    when City
      base + "cities/show/#{object.id}"
    when Country
      base + "countries/show/#{object.id}"
    when Carrier
      base + "carriers/show/#{object.id}"
    end
  end
end
