carrier "UX"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "8%"
agent_comment "5% от всех опубл. тарифов на рейсы UX (В договоре Interline отдельно не прописан.)"
subagent_comment "3,5% от опубл. тарифов на собств. рейсы UX"
interline :no, :unconfirmed
example "svocdg"
example "cdgsvo svocdg/ab"
end

