carrier "CY"

rule 1 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
agent_comment "9% от всех опубл. тарифов на рейсы CY. (В договоре Interline не прописан.)"
subagent_comment "7% от опубликованных тарифов на рейсы CY."
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
agent_comment "??? 1р Interline не прописан"
subagent_comment "??? 0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

