carrier "SA"

rule 1 do
example "svocdg"
example "svocdg cdgsvo/ab"
agent_comment "1% от опубл. тарифов на собств. рейсы. SA и рейсы Interline"
subagent_comment "0,5% от опубл. тарифа на собств. рейсы SA и рейсы Interline"
interline :no, :yes
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

