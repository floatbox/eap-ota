carrier "CY"

rule 1 do
example "svocdg"
agent_comment "9% от всех опубл. тарифов на рейсы CY. (В договоре Interline не прописан.)"
subagent_comment "7% от опубликованных тарифов на рейсы CY."
discount "7%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "??? 1р Interline не прописан"
subagent_comment "??? 0р Interline не прописан"
interline :unconfirmed
discount "3.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

