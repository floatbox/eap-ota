carrier "WY"

rule 1 do
example "svocdg"
agent_comment "5% от опубл. тарифов на собств. рейсы WY (В договоре Interline не прописан.)"
subagent_comment "3% от опубл. тарифа на собств.рейсы WY"
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
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

