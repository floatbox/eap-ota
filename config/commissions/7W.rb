carrier "7W"

rule 1 do
ticketing_method "aviacenter"
agent "9%"
subagent "6.3%"
discount "7.3%"
agent_comment "9% от всех опубл. тарифов на собств.рейсы 7W"
subagent_comment "6,3% от опубл. тарифов на собств.рейсы 7W"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "4.5%"
agent_comment "5% от всех опубл. тарифов на рейсы Interline c участком 7W"
subagent_comment "3,5% от опубл. тарифов на рейсы Interline c участком 7W"
interline :yes
example "svocdg cdgsvo/ab"
end

