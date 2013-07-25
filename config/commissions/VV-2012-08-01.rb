carrier "VV", start_date: "2012-08-01"

example "leddok"
example "ledcdg"
agent "9% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV"
subagent "8,5% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV."
discount "4.75%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'RU') and not includes(city_iatas.first, 'MOW') and not includes(city_iatas.last, 'IEV') }
disabled "bankrupt"
no_commission "9%/8.5%"

example "svokbp/business kbpsvo/business"
agent "9% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
classes :business
routes "MOW-IEV/OW,RT"
discount "3%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "5%/4.5%"

example "svokbp kbpsvo"
agent "7% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
routes "MOW-IEV/OW,RT"
discount "3%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "5%/4.5%"

example "kbpdok"
example "kbptbs"
example "tbstlv"
agent "1% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
subagent "5 рублей от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
consolidator "2%"
our_markup "60"
ticketing_method "aviacenter"
check %{ not includes(country_iatas.first, 'RU') }
disabled "bankrupt"
no_commission "1%/5"

example "kbpsvo/ab svokbp"
agent "5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
subagent "4,5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
interline :yes
discount "3%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "5%/4.5%"

example "kbpsvo/ab svokbp/ab"
agent "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
subagent "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "0%/0%"

example "svosip"
example "svoods"
interline :no, :yes, :absent
routes "...SIP,ODS..."
important!
disabled "bankrupt"
no_commission "Катя просила выключить срочно от 14.06.12"

