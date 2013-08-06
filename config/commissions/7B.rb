carrier "7B"

rule 1 do
example "svocdg"
agent_comment "4% от всех опубл. тарифов на cобств. рейсы 7B"
subagent_comment "2,8% от опубл. тарифов на cобств. рейсы 7B"
ticketing_method "aviacenter"
disabled "Suspension of Moscow Airlines (7B/499)"
agent "4%"
subagent "2.8%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "3% от всех опубл. тарифов на рейсы Interline"
subagent_comment "2% от опубл. тарифов на рейсы Interline"
interline :yes
ticketing_method "aviacenter"
disabled "Suspension of Moscow Airlines (7B/499)"
agent "3%"
subagent "2%"
end

rule 3 do
example "svocdg/ab"
no_commission
end

