carrier "OM", start_date: "2013-08-07"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "2.5%"
agent_comment "5% от всех опубл. тарифов на рейсы OM (В договоре Interline не прописан.)"
subagent_comment "2.5% от всех опубл. тарифов на рейсы OM"
interline :no, :unconfirmed
example "svocdg"
end

