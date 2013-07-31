carrier "CA"

example "ledpek"
example "svopek peksvo"
agent "9% Все международные перелеты рейсами СА из России"
subagent "7.5% Все международные перелеты рейсами СА из России"
routes "RU..."
important!
discount "7.5%"
ticketing_method "aviacenter"
commission "9%/7.5%"

example "ledpek/ab pekhta"
example "okopek/ab pekoko"
example "pekycu ycupek"
example "peksgn"
agent "3%  от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
subagent "2.5% от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
interline :no, :yes
discount "0%"
ticketing_method "aviacenter"
commission "3%/2.5%"

example "okopek/ab"
agent "  0% интерлайн без участия авиакомпании  CA ."
subagent "  0% интерлайн без участия авиакомпании  CA ."
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

