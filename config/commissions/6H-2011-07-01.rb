carrier "6H", start_date: "2011-07-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "3%"
agent_comment "С 01.07.11г. 5% от всех опубл. тарифов на рейсы 6H (В договоре Interline отдельно не прописан.)"
subagent_comment "С 01.07.11г. 3% от опубл. тарифов на собств.рейсы 6H"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1"
subagent "0"
consolidator "2%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

