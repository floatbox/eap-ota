carrier "7W"

rule 1 do
example "svocdg"
agent_comment "9% от всех опубл. тарифов на собств.рейсы 7W"
subagent_comment "6,3% от опубл. тарифов на собств.рейсы 7W"
discount "6.3%"
ticketing_method "aviacenter"
agent "9%"
subagent "6.3%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "5% от всех опубл. тарифов на рейсы Interline c участком 7W"
subagent_comment "3,5% от опубл. тарифов на рейсы Interline c участком 7W"
interline :yes
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

