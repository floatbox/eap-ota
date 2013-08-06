carrier "KM"

rule 1 do
example "svocdg"
agent_comment "1% от опубл. тарифов на собств. рейсы KM"
subagent_comment "0,5% от опубл. тарифа на рейсы KM"
discount "0%"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "1% от опубл. тарифов на рейсы Interline"
subagent_comment "0,5% от опубл. тарифа на рейсы Interline"
interline :yes
discount "0%"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

