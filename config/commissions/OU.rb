carrier "OU"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "1.35%"
agent_comment "1% от всех опубл. тарифов на рейсы OU"
subagent_comment "0,5% от опубл. тарифа на собств.рейсы OU"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "1.35%"
agent_comment "1% от опубл. тарифов на рейсы Interline с участком OU."
subagent_comment "0,5% от опубл. тарифа на рейсы Interline с участком OU."
interline :yes
example "svocdg cdgsvo/ab"
end

rule 3 do
no_commission
example "cdgsvo/ab"
end

