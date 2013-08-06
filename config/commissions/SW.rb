carrier "SW"

rule 1 do
example "svocdg"
agent_comment "1% от опубл. тарифов на собств. рейсы SW (В договоре Interline отдельно не прописан.)"
subagent_comment "5руб от опубл. тарифов на собств.рейсы SW"
interline :no, :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

