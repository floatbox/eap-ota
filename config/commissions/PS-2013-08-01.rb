carrier "PS", start_date: "2013-08-01"

example "svocdg"
example "svocdg cdgsvo"
agent "Для перевозок, содержащих участок в/из пунктов РФ:"
agent "5% (3%) (3%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в Москвы;"
discount "2.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') and includes(city_iatas, 'MOW LED') }
commission "5%/3%"

example "svxcdg"
example "svxcdg cdgsvx"
agent "7% (5%) (5%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в пунктов в РФ, кроме Москвы;"
discount "4%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') and not includes(city_iatas, 'MOW LED') }
commission "7%/5%"

example "svocdg/business"
example "svocdg/business cdgsvo/business"
agent "7% от тарифа Бизнес класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) из/в пунктов в РФ;"
subagent "5%"
classes :business
important!
discount "4%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') }
commission "7%/5%"

example "cdgsvo svocdg/ab"
agent "5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent "3% от опубл. тарифов на рейсы Interline c обязательным участком PS"
interline :yes
discount "2.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') }
commission "5%/3%"

example "cdgsvo/ab"
agent "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') }
commission "0%/0%"

example "ievcdg"
comment "для несодержащих РФ перевозок"
agent "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на собственных и совместных рейсах Авиакомпании под кодом PS (566)"
subagent "5 р"
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas, 'RU') }
commission "1%/5"

example "cdgiev ievcdg/ab"
comment "для несодержащих РФ перевозок"
agent "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на рейсы Interline с участком PS;"
subagent "5р + 2% сбор ац"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas, 'RU') }
commission "1%/5"

example "cdgiev/ab"
comment "для несодержащих РФ перевозок"
agent "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas, 'RU') }
commission "0%/0%"

