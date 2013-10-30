carrier "PS", start_date: "2013-08-01"

rule 1 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "Для перевозок, содержащих участок в/из пунктов РФ:"
agent_comment "5% (3%) (3%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в Москвы;"
check %{ includes(country_iatas, 'RU') and includes(city_iatas, 'MOW LED') }
example "svocdg"
example "svocdg cdgsvo"
end

rule 2 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7% (5%) (5%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в пунктов в РФ, кроме Москвы;"
check %{ includes(country_iatas, 'RU') and not includes(city_iatas, 'MOW LED') }
example "svxcdg"
example "svxcdg cdgsvx"
end

rule 3 do
disabled "переключили на downtown"
important!
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7% от тарифа Бизнес класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) из/в пунктов в РФ;"
subagent_comment "5%"
classes :business
check %{ includes(country_iatas, 'RU') }
example "svocdg/business"
example "svocdg/business cdgsvo/business"
end

rule 4 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent_comment "3% от опубл. тарифов на рейсы Interline c обязательным участком PS"
interline :yes
check %{ includes(country_iatas, 'RU') }
example "cdgsvo svocdg/ab"
end

rule 5 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
agent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
check %{ includes(country_iatas, 'RU') }
example "cdgsvo/ab"
end

rule 6 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
consolidator "2%"
comment "для несодержащих РФ перевозок"
agent_comment "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на собственных и совместных рейсах Авиакомпании под кодом PS (566)"
subagent_comment "5 р"
check %{ not includes(country_iatas, 'RU') }
example "ievcdg"
end

rule 7 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
consolidator "2%"
comment "для несодержащих РФ перевозок"
agent_comment "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на рейсы Interline с участком PS;"
subagent_comment "5р + 2% сбор ац"
interline :yes
check %{ not includes(country_iatas, 'RU') }
example "cdgiev ievcdg/ab"
end

rule 8 do
disabled "переключили на downtown"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
comment "для несодержащих РФ перевозок"
agent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
check %{ not includes(country_iatas, 'RU') }
example "cdgiev/ab"
end

rule 9 do
important!
ticketing_method "downtown"
agent "7%"
subagent "6%"
discount "8.5%"
agent_comment "все через dtt"
example "svocdg"
example "svocdg cdgsvo"
end

