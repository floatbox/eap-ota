carrier "D9"

example "svocdg/economy"
agent "7% от опубл. тарифов эконом класса на собств. рейсы D9"
subagent "5% от опубл. тарифов эконом класса на собств. рейсы D9"
classes :economy
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svocdg/business"
agent "9% от опубл. тарифов бизнес класса на собств. рейсы D9"
subagent "6,3% от опубл. тарифов бизнес класса на собств. рейсы D9"
classes :business
discount "6.3%"
ticketing_method "aviacenter"
commission "9%/6.3%"

example "svocdg cdgsvo/ab"
example "svocdg/business cdgsvo/ab"
agent "2% от опубл. тарифов на рейсы Interline с участком D9"
subagent "1,4% от опубл. тарифов на рейсы Interline с участком D9"
interline :yes
discount "0%"
ticketing_method "aviacenter"
commission "2%/1.4%"

