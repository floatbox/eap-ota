carrier "CQ"

rule 1 do
disabled "Перестали летать"
ticketing_method "aviacenter"
agent "6%"
subagent "4%"
discount "2%"
agent_comment "6% от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent_comment "4% от всех опубл. тарифов на собств. рейсы CQ"
interline :no, :unconfirmed
example "svocdg"
end

