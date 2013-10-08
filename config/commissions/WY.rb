carrier "WY"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "2.1%"
agent_comment "5% от опубл. тарифов на собств. рейсы WY (В договоре Interline не прописан.)"
subagent_comment "3% от опубл. тарифа на собств.рейсы WY"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

