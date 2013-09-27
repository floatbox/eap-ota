carrier "PG"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "1.75%"
agent_comment "5% от всех опубл. тарифов на рейсы PG (В договоре Interline не прописан.)"
subagent_comment "3,5% от опубликованных тарифов на рейсы PG"
interline :no, :unconfirmed
example "svocdg"
example "cdgsvo svocdg/ab"
end

