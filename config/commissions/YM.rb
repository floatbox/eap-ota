carrier "YM"

rule 1 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "8%"
subagent "6%"
agent_comment "8% от всех опубл. тарифов на рейсы YM (В договоре Interline не прописан.)"
subagent_comment "6% от всех опубл. тарифов на рейсы YM"
interline :no, :unconfirmed
example "svocdg"
example "cdgsvo svocdg/ab"
end

