carrier "ET"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7% от опубл. тарифов на собств. рейсы ET"
subagent_comment "5% от опубл. тарифов на собств. рейсы ET"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "4.5%"
agent_comment "5 % от опубл. тарифов на рейсы Interline с участком ET"
subagent_comment "3,5 % от опубл. тарифов на рейсы Interline с участком ET"
interline :yes
example "svocdg cdgsvo/ab"
end

rule 3 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "2.5%"
consolidator "2%"
agent_comment "0 % от опубл. тарифов на рейсы Interline без участка ET"
subagent_comment "0 % от опубл. тарифов на рейсы Interline без участка ET"
interline :absent
example "cdgsvo/ab"
end

