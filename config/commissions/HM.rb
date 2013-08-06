carrier "HM"

rule 1 do
example "svocdg"
agent_comment "1% от опубл. тарифа на собств. рейсы HM (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на собств. рейсы HM"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

