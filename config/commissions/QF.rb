carrier "QF"

rule 1 do
disabled "not bsp"
ticketing_method "aviacenter"
agent "7%"
subagent "4.9%"
agent_comment "7% от опубл. тарифов на рейсы QF (В договоре Interline не прописан.)"
subagent_comment "4,9% от опубл. тарифов на рейсы QF"
interline :no, :unconfirmed
example "svocdg"
end

