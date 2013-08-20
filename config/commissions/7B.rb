carrier "7B"

rule 1 do
disabled "Suspension of Moscow Airlines (7B/499)"
ticketing_method "aviacenter"
agent "4%"
subagent "2.8%"
discount "2.8%"
agent_comment "4% от всех опубл. тарифов на cобств. рейсы 7B"
subagent_comment "2,8% от опубл. тарифов на cобств. рейсы 7B"
example "svocdg"
end

rule 2 do
disabled "Suspension of Moscow Airlines (7B/499)"
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "2%"
agent_comment "3% от всех опубл. тарифов на рейсы Interline"
subagent_comment "2% от опубл. тарифов на рейсы Interline"
interline :yes
example "cdgsvo svocdg/ab"
end

rule 3 do
no_commission
example "svocdg/ab"
end

