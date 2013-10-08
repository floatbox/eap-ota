carrier "RC"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "2.1%"
agent_comment "5% от всех опубл.тарифов на собств. рейсы авиакомпании. (Interline отдельно не прописан)"
subagent_comment "3% от всех опубл. тарифов на собств. рейсы RC"
interline :no, :unconfirmed
example "svocdg"
example "svocdg cdgsvo/ab"
end

