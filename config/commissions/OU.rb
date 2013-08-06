carrier "OU"

rule 1 do
example "svocdg"
agent_comment "1% от всех опубл. тарифов на рейсы OU"
subagent_comment "0,5% от опубл. тарифа на собств.рейсы OU"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "1% от опубл. тарифов на рейсы Interline с участком OU."
subagent_comment "0,5% от опубл. тарифа на рейсы Interline с участком OU."
interline :yes
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 3 do
example "cdgsvo/ab"
no_commission
end

