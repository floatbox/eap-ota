carrier "EY"

rule 1 do
example "svocdg"
agent_comment "5% от опубл. тарифов на собств. рейсы EY (В договоре Interline не прописан.)"
subagent_comment "3.5% от опубл. тарифов на собств. рейсы EY (В договоре Interline не прописан.)"
discount "2.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0"
end

