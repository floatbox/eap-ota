carrier "JJ"

rule 1 do
example "svocdg"
agent_comment "1% от всех опубл. тарифов на собств. рейсы JJ (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на собств.рейсы JJ"
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

