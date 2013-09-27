carrier "BI"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.25%"
agent_comment "1% от опубл. тарифов на собств. рейсы BI (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на собств. рейсы BI"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.25%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

