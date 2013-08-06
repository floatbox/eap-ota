carrier "CA"

rule 1 do
example "ledpek"
example "svopek peksvo"
agent_comment "9% Все международные перелеты рейсами СА из России"
subagent_comment "7.5% Все международные перелеты рейсами СА из России"
routes "RU..."
important!
discount "7.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7.5%"
end

rule 2 do
example "ledpek/ab pekhta"
example "okopek/ab pekoko"
example "pekycu ycupek"
example "peksgn"
agent_comment "3%  от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
subagent_comment "2.5% от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
interline :no, :yes
discount "0%"
ticketing_method "aviacenter"
agent "3%"
subagent "2.5%"
end

rule 3 do
example "okopek/ab"
agent_comment "  0% интерлайн без участия авиакомпании  CA ."
subagent_comment "  0% интерлайн без участия авиакомпании  CA ."
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

