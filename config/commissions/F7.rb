carrier "F7"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "3.5%"
agent_comment "1% от опубл. тарифов на собств.рейсы F7"
subagent_comment "0,5% от опубл. тарифа на рейсы F7"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0%"
discount "3%"
consolidator "2%"
agent_comment "1% от опубл. тар. на рейсы Interline c участком F7"
subagent_comment "0,5% от опубл. тарифа на рейсы F7"
interline :yes
example "svocdg cdgsvo/ab"
end

rule 3 do
ticketing_method "aviacenter"
agent "1%"
subagent "0%"
discount "3%"
consolidator "2%"
agent_comment "1% от опубл. тар. на рейсы Interline без участка F7"
subagent_comment "0,5% от опубл. тарифа на рейсы F7"
interline :absent
example "cdgsvo/ab"
end

