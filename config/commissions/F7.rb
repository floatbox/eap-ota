carrier "F7"

example "svocdg"
agent "1% от опубл. тарифов на собств.рейсы F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "svocdg cdgsvo/ab"
agent "1% от опубл. тар. на рейсы Interline c участком F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/0%"

example "cdgsvo/ab"
agent "1% от опубл. тар. на рейсы Interline без участка F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/0%"

