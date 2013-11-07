carrier "OV"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.15%"
agent_comment "1% от всех опубл. тарифов на рейсы OV (В договоре Interline не прописан.)"
subagent_comment "0,5% от опубл. тарифа на рейсы OV"
interline :no, :unconfirmed
example "svocdg"
example "cdgsvo svocdg/ab"
end

