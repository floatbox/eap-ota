carrier "SA"

rule 1 do
ticketing_method "direct"
agent "1%"
subagent "0.5%"
agent_comment "1% от опубл. тарифов на собств. рейсы. SA и рейсы Interline"
subagent_comment "0,5% от опубл. тарифа на собств. рейсы SA и рейсы Interline"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

