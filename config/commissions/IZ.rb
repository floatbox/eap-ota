carrier "IZ"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "7.75%"
agent_comment "7% от всех опубл. тарифов; (Interline отдельно не прописан)"
subagent_comment "5% от всех опубл.тарифов на собств. рейсы IZ"
interline :no, :unconfirmed
example "svocdg"
end

