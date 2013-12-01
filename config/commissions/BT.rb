carrier "BT"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
discount "3% + 0.5"
consolidator "2%"
agent_comment "1 руб. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT"
subagent_comment "50 КОП. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT +2% сбор АЦ"
interline :no, :yes
example "svocdg cdgsvo"
example "svocdg cdgsvo/ab"
end

rule 2 do
no_commission "Катя просила выключить"
important!
subclasses "V"
routes "...RIX..."
example "svorix/v"
example "svorix/v rixsvo/v"
end

