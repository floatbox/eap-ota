carrier "HY"

rule 1 do
example "svocdg"
agent_comment "7% от опубл. тарифов на собств. рейсы HY"
subagent_comment "5% от опубл. тарифов на собств. рейсы HY"
discount "2.5%"
ticketing_method "aviacenter"
disabled "не bsp"
agent "7%"
subagent "5%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "0% от опубл. тарифов на рейсы Interline"
subagent_comment "0% от опубл. тарифов на рейсы Interline"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
disabled "не bsp"
agent "0%"
subagent "0%"
end

