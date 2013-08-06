carrier "CQ"

rule 1 do
example "svocdg"
agent_comment "6% от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent_comment "4% от всех опубл. тарифов на собств. рейсы CQ"
interline :no, :unconfirmed
discount "2%"
ticketing_method "aviacenter"
disabled "Перестали летать"
agent "6%"
subagent "4%"
end

