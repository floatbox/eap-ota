carrier "PS", start_date: "2013-06-20"

rule 1 do
example "svocdg"
example "svocdg cdgsvo"
agent_comment "Для перевозок, содержащих участок в/из пунктов РФ:"
agent_comment "5% (3%) (3%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в Москвы;"
discount "2.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') and includes(city_iatas, 'MOW') }
agent "5%"
subagent "3%"
end

rule 2 do
example "ledcdg"
example "ledcdg cdgled"
agent_comment "7% (5%) (5%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в пунктов в РФ, кроме Москвы;"
discount "4%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') and not includes(city_iatas, 'MOW') }
agent "7%"
subagent "5%"
end

rule 3 do
example "svocdg/business"
example "svocdg/business cdgsvo/business"
agent_comment "9% (7%) (7%) от тарифа Бизнес класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) из/в пунктов в РФ;"
subagent_comment "7%"
classes :business
important!
discount "5.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') }
agent "9%"
subagent "7%"
end

rule 4 do
example "cdgsvo svocdg/ab"
agent_comment "5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent_comment "3% от опубл. тарифов на рейсы Interline c обязательным участком PS"
interline :yes
discount "2.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') }
agent "5%"
subagent "3%"
end

rule 5 do
example "cdgsvo/ab"
agent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas, 'RU') }
agent "0%"
subagent "0%"
end

rule 6 do
example "ievcdg"
comment "для несодержащих РФ перевозок"
agent_comment "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на собственных и совместных рейсах Авиакомпании под кодом PS (566)"
subagent_comment "5 р"
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas, 'RU') }
agent "1%"
subagent "5"
end

rule 7 do
example "cdgiev ievcdg/ab"
comment "для несодержащих РФ перевозок"
agent_comment "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на рейсы Interline с участком PS;"
subagent_comment "5р + 2% сбор ац"
interline :yes
discount "1.5%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas, 'RU') }
agent "5%"
subagent "3%"
end

rule 8 do
example "cdgiev/ab"
comment "для несодержащих РФ перевозок"
agent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent_comment "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas, 'RU') }
agent "0%"
subagent "0%"
end

