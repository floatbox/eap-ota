carrier "RJ"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "5 (пять) % от всех опубл. тарифов на собств. рейсы RJ"
subagent_comment "3% от опубл. тарифов на собств. рейсы RJ"
example "svocdg cdgsvo"
end

rule 2 do
no_commission
agent_comment "interline нет в договоре"
interline :yes, :absent
example "svocdg/ab cdgsvo"
end

