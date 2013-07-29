carrier "AT"

example "svocdg"
agent "5% от опубл. тарифов Эконом класса на собств. рейсы АТ"
subagent "3% от опубл. тарифов Эконом класса на собств. рейсы АТ"
classes :economy
discount "1.5%"
ticketing_method "aviacenter"
commission "5%/3%"

example "svocdg/business"
agent "7% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
subagent "5% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
classes :business
discount "2.5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svocdg cdgsvo/ab"
interline :yes, :absent
no_commission

