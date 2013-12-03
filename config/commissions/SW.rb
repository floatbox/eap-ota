carrier "SW"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "4.5%"
consolidator "2%"
agent_comment "1% от опубл. тарифов на собств. рейсы SW (В договоре Interline отдельно не прописан.)"
subagent_comment "5руб от опубл. тарифов на собств.рейсы SW"
interline :no, :unconfirmed
example "svocdg"
end

