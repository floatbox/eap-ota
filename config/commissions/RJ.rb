carrier "RJ"

example "svocdg cdgsvo"
agent "5 (пять) % от всех опубл. тарифов на собств. рейсы RJ"
subagent "3% от опубл. тарифов на собств. рейсы RJ"
discount "1.5%"
ticketing_method "aviacenter"
commission "5%/3%"

example "svocdg/ab cdgsvo"
agent "interline нет в договоре"
interline :yes, :absent
no_commission

