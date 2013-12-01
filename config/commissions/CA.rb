carrier "CA"

rule 1 do
important!
ticketing_method "aviacenter"
agent "9%"
subagent "7.5%"
discount "10.5%"
agent_comment "9% Все международные перелеты рейсами СА из России"
subagent_comment "7.5% Все международные перелеты рейсами СА из России"
routes "RU..."
example "ledpek"
example "svopek peksvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "3%"
subagent "2.5%"
discount "5.5%"
agent_comment "3%  от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
subagent_comment "2.5% от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
interline :no, :yes
example "ledpek/ab pekhta"
example "okopek/ab pekoko"
example "pekycu ycupek"
example "peksgn"
end

rule 3 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "3%"
consolidator "2%"
agent_comment "  0% интерлайн без участия авиакомпании  CA ."
subagent_comment "  0% интерлайн без участия авиакомпании  CA ."
interline :absent
example "okopek/ab"
end

