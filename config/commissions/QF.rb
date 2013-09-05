carrier "QF", no_commission: "not bsp"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "4.9%"
discount "5.9%"
agent_comment "7% от опубл. тарифов на рейсы QF (В договоре Interline не прописан.)"
subagent_comment "4,9% от опубл. тарифов на рейсы QF"
interline :no, :unconfirmed
example "svocdg"
end

