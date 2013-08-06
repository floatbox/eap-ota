carrier "TP"

rule 1 do
example "svocdg cdgsvo"
agent_comment "1% от опубл. тарифов на собств. рейсы TP и рейсы Interline"
subagent_comment "0,5% от опубл. тарифа на собственные рейсы TP и рейсы Interline"
interline :no, :yes
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

