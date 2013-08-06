carrier "RC"

rule 1 do
example "svocdg"
example "svocdg cdgsvo/ab"
agent_comment "5% от всех опубл.тарифов на собств. рейсы авиакомпании. (Interline отдельно не прописан)"
subagent_comment "3% от всех опубл. тарифов на собств. рейсы RC"
interline :no, :unconfirmed
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

