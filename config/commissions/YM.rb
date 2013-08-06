carrier "YM"

rule 1 do
example "svocdg"
example "cdgsvo svocdg/ab"
agent_comment "8% от всех опубл. тарифов на рейсы YM (В договоре Interline не прописан.)"
subagent_comment "6% от всех опубл. тарифов на рейсы YM"
interline :no, :unconfirmed
discount "6%"
ticketing_method "aviacenter"
agent "8%"
subagent "6%"
end

