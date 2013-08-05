carrier "BT"

example "svocdg cdgsvo"
example "svocdg cdgsvo/ab"
agent "1 руб. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT"
subagent "50 КОП. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT +2% сбор АЦ"
interline :no, :yes
consolidator "2%"
discount "1.5%"
ticketing_method "aviacenter"
commission "1/0.5"

example "svorix/v"
example "svorix/v rixsvo/v"
subclasses "V"
routes "...RIX..."
important!
no_commission "Катя просила выключить"

