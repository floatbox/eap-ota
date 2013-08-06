carrier "VV", start_date: "2012-08-01"

rule 1 do
disabled "bankrupt"
no_commission "9%/8.5%"
ticketing_method "aviacenter"
discount "4.75%"
agent_comment "9% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV"
subagent_comment "8,5% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV."
check %{ includes(country_iatas.first, 'RU') and not includes(city_iatas.first, 'MOW') and not includes(city_iatas.last, 'IEV') }
example "leddok"
example "ledcdg"
end

rule 2 do
disabled "bankrupt"
no_commission "5%/4.5%"
ticketing_method "aviacenter"
discount "3%"
agent_comment "9% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent_comment "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
classes :business
routes "MOW-IEV/OW,RT"
example "svokbp/business kbpsvo/business"
end

rule 3 do
disabled "bankrupt"
no_commission "5%/4.5%"
ticketing_method "aviacenter"
discount "3%"
agent_comment "7% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent_comment "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
routes "MOW-IEV/OW,RT"
example "svokbp kbpsvo"
end

rule 4 do
disabled "bankrupt"
no_commission "1%/5"
ticketing_method "aviacenter"
our_markup "60"
consolidator "2%"
agent_comment "1% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
subagent_comment "5 рублей от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
check %{ not includes(country_iatas.first, 'RU') }
example "kbpdok"
example "kbptbs"
example "tbstlv"
end

rule 5 do
disabled "bankrupt"
no_commission "5%/4.5%"
ticketing_method "aviacenter"
discount "3%"
agent_comment "5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
subagent_comment "4,5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
interline :yes
example "kbpsvo/ab svokbp"
end

rule 6 do
disabled "bankrupt"
no_commission "0%/0%"
ticketing_method "aviacenter"
consolidator "2%"
agent_comment "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
subagent_comment "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
interline :absent
example "kbpsvo/ab svokbp/ab"
end

rule 7 do
disabled "bankrupt"
no_commission "Катя просила выключить срочно от 14.06.12"
important!
interline :no, :yes, :absent
routes "...SIP,ODS..."
example "svosip"
example "svoods"
end

