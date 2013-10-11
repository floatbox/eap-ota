carrier "HM"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "2.35%"
agent_comment "1% от опубл. тарифа на собств. рейсы HM (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на собств. рейсы HM"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "2.35%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

