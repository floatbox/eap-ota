carrier "LY"

example "svocdg"
agent "5% от опубл. тарифов Эконом класса на рейсы LY"
subagent "3,5% от опубл. тарифов Эконом класса на рейсы LY"
classes :economy
discount "1.75%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg/j cdgsvo/j"
agent "5% от опубл. тарифов Бизнес класса J на рейсы LY"
subagent "3,5% от опубл. тарифов Бизнес класса J на рейсы LY"
subclasses "J"
important!
discount "1.75%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg/business cdgsvo/business"
agent "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
classes :business
discount "3.35%"
ticketing_method "aviacenter"
commission "9.7%/6.7%"

example "svocdg cdgsvo/business"
example "svocdg cdgsvo/ab"
no_commission

