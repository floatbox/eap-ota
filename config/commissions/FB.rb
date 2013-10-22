carrier "FB"

rule 1 do
ticketing_method "aviacenter"
agent "4%"
subagent "2.8%"
discount "4.9%"
agent_comment "4% от опубл. тарифов на собств. рейсы FB. (В договоре Interline не прописан.)"
subagent_comment "2,8% от опубл. тарифов на собств. рейсы FB."
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "4%"
subagent "2.8%"
discount "4.9%"
agent_comment "??? 1р Interline не прописан"
subagent_comment "??? 0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

