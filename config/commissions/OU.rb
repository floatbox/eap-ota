carrier "OU"

example "svocdg"
agent "1% от всех опубл. тарифов на рейсы OU"
subagent "0,5% от опубл. тарифа на собств.рейсы OU"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "svocdg cdgsvo/ab"
agent "1% от опубл. тарифов на рейсы Interline с участком OU."
subagent "0,5% от опубл. тарифа на рейсы Interline с участком OU."
interline :yes
ticketing_method "aviacenter"
commission "1%/0.5%"

example "cdgsvo/ab"
no_commission

