carrier "VV", start_date: "2012-08-01"

rule 1 do
example "leddok"
example "ledcdg"
agent_comment "9% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV"
subagent_comment "8,5% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV."
discount "4.75%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'RU') and not includes(city_iatas.first, 'MOW') and not includes(city_iatas.last, 'IEV') }
disabled "bankrupt"
no_commission "9%/8.5%"
end

rule 2 do
example "svokbp/business kbpsvo/business"
agent_comment "9% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent_comment "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
classes :business
routes "MOW-IEV/OW,RT"
discount "3%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "5%/4.5%"
end

rule 3 do
example "svokbp kbpsvo"
agent_comment "7% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent_comment "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
routes "MOW-IEV/OW,RT"
discount "3%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "5%/4.5%"
end

rule 4 do
example "kbpdok"
example "kbptbs"
example "tbstlv"
agent_comment "1% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
subagent_comment "5 рублей от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
consolidator "2%"
our_markup "60"
ticketing_method "aviacenter"
check %{ not includes(country_iatas.first, 'RU') }
disabled "bankrupt"
no_commission "1%/5"
end

rule 5 do
example "kbpsvo/ab svokbp"
agent_comment "5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
subagent_comment "4,5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
interline :yes
discount "3%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "5%/4.5%"
end

rule 6 do
example "kbpsvo/ab svokbp/ab"
agent_comment "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
subagent_comment "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
disabled "bankrupt"
no_commission "0%/0%"
end

rule 7 do
example "svosip"
example "svoods"
interline :no, :yes, :absent
routes "...SIP,ODS..."
important!
disabled "bankrupt"
no_commission "Катя просила выключить срочно от 14.06.12"
end

