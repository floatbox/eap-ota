carrier "2U"

rule 1 do
example "svocdg"
example "cdgsvo svocdg/ab"
agent_comment "5% от опубл. тарифов на собств. рейсы 2U (В договоре Interline отдельно не прописан.)"
agent_comment "Interline не прописан"
subagent_comment "3,5% от опубл. тарифов на собств. рейсы 2U"
subagent_comment "Interline не прописан"
interline :no, :unconfirmed
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

