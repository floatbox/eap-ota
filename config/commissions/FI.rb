carrier "FI"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.5%"
agent_comment "1% от всех опубл. тарифов на рейсы FI (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на рейсы FI"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.5%"
agent_comment "1% от опубл. тарифов на рейсы Interline с обязательным участием FI."
subagent_comment "0,5% от опубл. тарифов на рейсы Interline с обязательным участием FI."
interline :yes
example "cdgsvo svocdg/ab"
end

