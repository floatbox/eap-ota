carrier "DE", start_date: "2011-10-01"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
consolidator "2%"
agent_comment "1руб от всех опубл. тарифов на рейсы DE. (В договоре Interline не прописан.)"
subagent_comment "5 коп от опубл. тарифа на рейсы DE."
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.05"
consolidator "2%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

