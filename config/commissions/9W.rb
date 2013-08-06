carrier "9W"

rule 1 do
example "svocdg"
example "cdgsvo svocdg/ab"
agent_comment "1% от опубл. тарифов на собств.рейсы 9W"
agent_comment "1% от опубл. тарифов на рейсы Interline с участком 9W (Выписка без участка 9W запрещена.)"
subagent_comment "0,5% от опубл. тарифа на собств.рейсы 9W"
interline :no, :yes
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "cdgsvo/ab"
no_commission
end

