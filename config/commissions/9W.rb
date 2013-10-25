carrier "9W"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
agent_comment "1% от опубл. тарифов на собств.рейсы 9W"
agent_comment "1% от опубл. тарифов на рейсы Interline с участком 9W (Выписка без участка 9W запрещена.)"
subagent_comment "0,5% от опубл. тарифа на собств.рейсы 9W"
interline :no, :yes
example "svocdg"
example "cdgsvo svocdg/ab"
end

rule 2 do
no_commission
example "cdgsvo/ab"
end

