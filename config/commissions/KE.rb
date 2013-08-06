carrier "KE"

rule 1 do
example "svogmp"
agent_comment "С 01.04.2011г. 5% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
subagent_comment "С 01.04.2011г. 3% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
routes "RU..."
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 2 do
example "gmpsvo"
agent_comment "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
subagent_comment "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas.first, 'RU') }
agent "0%"
subagent "0%"
end

rule 3 do
example "svoicn icnsvo/ab"
no_commission
end

