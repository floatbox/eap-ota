carrier "ET"

rule 1 do
example "svocdg"
agent_comment "7% от опубл. тарифов на собств. рейсы ET"
subagent_comment "5% от опубл. тарифов на собств. рейсы ET"
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "5 % от опубл. тарифов на рейсы Interline с участком ET"
subagent_comment "3,5 % от опубл. тарифов на рейсы Interline с участком ET"
interline :yes
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 3 do
example "cdgsvo/ab"
agent_comment "0 % от опубл. тарифов на рейсы Interline без участка ET"
subagent_comment "0 % от опубл. тарифов на рейсы Interline без участка ET"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

