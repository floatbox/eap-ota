carrier "ET"

example "svocdg"
agent "7% от опубл. тарифов на собств. рейсы ET"
subagent "5% от опубл. тарифов на собств. рейсы ET"
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svocdg cdgsvo/ab"
agent "5 % от опубл. тарифов на рейсы Interline с участком ET"
subagent "3,5 % от опубл. тарифов на рейсы Interline с участком ET"
interline :yes
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "cdgsvo/ab"
agent "0 % от опубл. тарифов на рейсы Interline без участка ET"
subagent "0 % от опубл. тарифов на рейсы Interline без участка ET"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

