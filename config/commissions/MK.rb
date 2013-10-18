carrier "MK"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.4%"
agent_comment "1% от опубл. тарифов на рейсы MK (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на рейсы MK"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.4%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

