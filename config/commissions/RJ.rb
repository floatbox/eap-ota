carrier "RJ"

rule 1 do
example "svocdg cdgsvo"
agent_comment "5 (пять) % от всех опубл. тарифов на собств. рейсы RJ"
subagent_comment "3% от опубл. тарифов на собств. рейсы RJ"
discount "2.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 2 do
example "svocdg/ab cdgsvo"
agent_comment "interline нет в договоре"
interline :yes, :absent
no_commission
end

