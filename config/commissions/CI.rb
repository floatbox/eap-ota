carrier "CI"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
agent_comment "1% от всех опубл. тарифов на рейсы CI (В договоре Interline отдельно не прописан.)"
subagent_comment "0,5% от опубл. тарифа на собств. рейсы CI"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0"
consolidator "2%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

