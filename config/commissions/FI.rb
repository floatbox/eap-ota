carrier "FI"

rule 1 do
example "svocdg"
agent_comment "1% от всех опубл. тарифов на рейсы FI (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на рейсы FI"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1% от опубл. тарифов на рейсы Interline с обязательным участием FI."
subagent_comment "0,5% от опубл. тарифов на рейсы Interline с обязательным участием FI."
interline :yes
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

