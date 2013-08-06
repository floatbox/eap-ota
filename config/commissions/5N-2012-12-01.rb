carrier "5N", start_date: "2012-12-01"

rule 1 do
example "svocdg"
agent_comment " 4% от всех опубликованных тарифов на рейсы 5N"
subagent_comment "3% от всех опубликованных тарифов на рейсы 5N"
discount "3%"
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :yes
discount "2.5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

