carrier "PS", start_date: "2014-01-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
agent_comment "Для перевозок, содержащих участок из пунктов РФ:"
agent_comment "5% (3%) (3%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из Москвы и Санкт-Петербурга;"
check %{ includes(country_iatas, 'RU') and includes(city_iatas.first, 'MOW LED') }
example "svocdg"
example "svocdg cdgsvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "8%"
agent_comment "7% (8%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из пунктов РФ, кроме Москвы и Петербурга;"
check %{ includes(country_iatas.first, 'RU') and not includes(city_iatas, 'MOW LED') }
example "svxcdg"
example "svxcdg cdgsvx"
end

rule 3 do
important!
ticketing_method "aviacenter"
agent "7%"
subagent "8%"
agent_comment "7% от тарифа Бизнес класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) из пунктов РФ;"
subagent_comment "8%"
classes :business
check %{ includes(country_iatas.first, 'RU') }
example "svocdg/business"
example "svocdg/business cdgsvo/business"
end

rule 4 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
agent_comment "5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent_comment "3% от опубл. тарифов на рейсы Interline c обязательным участком PS"
interline :yes
check %{ includes(country_iatas.first, 'RU') }
example "svocdg/ab cdgsvo"
end

rule 5 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
agent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
check %{ includes(country_iatas.first, 'RU') }
example "svocdg/ab"
end

rule 6 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
consolidator "2%"
comment "Не из РФ"
agent_comment "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на собственных и совместных рейсах Авиакомпании под кодом PS (566)"
subagent_comment "5 р"
check %{ not includes(country_iatas.first, 'RU') }
example "ievcdg"
end

rule 7 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
consolidator "2%"
comment "для несодержащих РФ перевозок"
agent_comment "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на рейсы Interline с участком PS;"
subagent_comment "5р + 2% сбор ац"
interline :yes
check %{ not includes(country_iatas.first, 'RU') }
example "cdgiev ievcdg/ab"
end

rule 8 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
comment "Не из РФ"
agent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
check %{ not includes(country_iatas.first, 'RU') }
example "cdgiev/ab"
end

rule 9 do
disabled "dtt disabled"
ticketing_method "downtown"
agent "7%"
subagent "6%"
agent_comment "все через dtt"
example "svocdg"
example "svocdg cdgsvo"
end

