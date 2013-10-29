carrier "5N", start_date: "2012-12-01"

rule 1 do
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
discount "5%"
agent_comment " 4% от всех опубликованных тарифов на рейсы 5N"
subagent_comment "3% от всех опубликованных тарифов на рейсы 5N"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "7%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :yes
example "cdgsvo svocdg/ab"
end

