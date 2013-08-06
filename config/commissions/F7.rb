carrier "F7"

rule 1 do
example "svocdg"
agent_comment "1% от опубл. тарифов на собств.рейсы F7"
subagent_comment "0,5% от опубл. тарифа на рейсы F7"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "1% от опубл. тар. на рейсы Interline c участком F7"
subagent_comment "0,5% от опубл. тарифа на рейсы F7"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "0%"
end

rule 3 do
example "cdgsvo/ab"
agent_comment "1% от опубл. тар. на рейсы Interline без участка F7"
subagent_comment "0,5% от опубл. тарифа на рейсы F7"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "0%"
end

