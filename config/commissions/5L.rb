carrier "5L"

rule 1 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
agent_comment "1% от опубл. тарифов на собств. рейсы 5L"
subagent_comment "0.5% с билета по опубл. тарифам на собств. рейсы 5L"
interline :no, :unconfirmed
example "svocdg"
end

