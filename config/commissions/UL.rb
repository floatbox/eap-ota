carrier "UL"

rule 1 do
example "svocdg"
example "cdgsvo svocdg/ab"
agent_comment "1% от всех опубл. тарифов на собств. рейсы UL (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на собств.рейсы UL"
interline :no, :unconfirmed
discount "0.25%"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

