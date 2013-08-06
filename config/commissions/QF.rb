carrier "QF"

rule 1 do
example "svocdg"
agent_comment "7% от опубл. тарифов на рейсы QF (В договоре Interline не прописан.)"
subagent_comment "4,9% от опубл. тарифов на рейсы QF"
interline :no, :unconfirmed
ticketing_method "aviacenter"
disabled "not bsp"
agent "7%"
subagent "4.9%"
end

