carrier "GW"

rule 1 do
example "svocdg"
agent_comment "5% от опубл. тарифов на собств. рейсы авиакомпании."
subagent_comment "3% от всех опубл. тарифов на собств. рейсы GW"
discount "0%"
ticketing_method "aviacenter"
disabled "bankrupt"
agent "5%"
subagent "3%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "3% от опубл. тарифов на рейсы Interline c обязательным участием GW. Выписка на рейсы Interline без участка GW запрещена."
subagent_comment "1% от всех опубл. тарифов на собств. рейсы GW"
interline :yes
discount "0%"
ticketing_method "aviacenter"
disabled "bankrupt"
agent "3%"
subagent "1%"
end

