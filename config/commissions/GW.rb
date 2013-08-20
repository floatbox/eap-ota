carrier "GW"

rule 1 do
disabled "bankrupt"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "3%"
agent_comment "5% от опубл. тарифов на собств. рейсы авиакомпании."
subagent_comment "3% от всех опубл. тарифов на собств. рейсы GW"
example "svocdg"
end

rule 2 do
disabled "bankrupt"
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
discount "1%"
agent_comment "3% от опубл. тарифов на рейсы Interline c обязательным участием GW. Выписка на рейсы Interline без участка GW запрещена."
subagent_comment "1% от всех опубл. тарифов на собств. рейсы GW"
interline :yes
example "svocdg cdgsvo/ab"
end

