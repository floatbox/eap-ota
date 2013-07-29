carrier "GW"

example "svocdg"
agent "5% от опубл. тарифов на собств. рейсы авиакомпании."
subagent "3% от всех опубл. тарифов на собств. рейсы GW"
discount "0%"
ticketing_method "aviacenter"
disabled "bankrupt"
commission "5%/3%"

example "svocdg cdgsvo/ab"
agent "3% от опубл. тарифов на рейсы Interline c обязательным участием GW. Выписка на рейсы Interline без участка GW запрещена."
subagent "1% от всех опубл. тарифов на собств. рейсы GW"
interline :yes
discount "0%"
ticketing_method "aviacenter"
disabled "bankrupt"
commission "3%/1%"

