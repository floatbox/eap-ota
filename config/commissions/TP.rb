carrier "TP"

rule 1 do
ticketing_method "direct"
agent "1%"
subagent "0.5%"
agent_comment "1% от опубл. тарифов на собств. рейсы TP и рейсы Interline"
subagent_comment "0,5% от опубл. тарифа на собственные рейсы TP и рейсы Interline"
interline :no, :yes
example "svocdg cdgsvo"
end

