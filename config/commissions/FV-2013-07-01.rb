carrier "FV", start_date: "2013-07-01"

example "svocdg"
example "svocdg cdgsvo/ab"
agent "4% (2%) (2%) от опубл. тарифов на собств. (включая code-share) рейсы FV и рейсы Interline c участком FV"
subagent "2% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
discount "1%"
ticketing_method "aviacenter"
commission "4%/2%"

example "svocdg/ab"
example "svocdg/ab cdgsvo/ab"
agent "1 euro  (5 руб+2% сбор АЦ) (0%) с билета на рейсы Interline без участка FV."
subagent "5 рублей"
interline :absent
ticketing_method "aviacenter"
commission "1eur/5"

example "svocdg/r"
subclasses "R"
important!
ticketing_method "aviacenter"
no_commission "закрыли субсидированные тарифы"

