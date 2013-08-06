carrier "FB"

rule 1 do
example "svocdg"
agent_comment "4% от опубл. тарифов на собств. рейсы FB. (В договоре Interline не прописан.)"
subagent_comment "2,8% от опубл. тарифов на собств. рейсы FB."
discount "1.4%"
ticketing_method "aviacenter"
agent "4%"
subagent "2.8%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "??? 1р Interline не прописан"
subagent_comment "??? 0р Interline не прописан"
interline :unconfirmed
discount "1.4%"
ticketing_method "aviacenter"
agent "4%"
subagent "2.8%"
end

