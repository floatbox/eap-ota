carrier "CY", start_date: "2013-10-01"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "1.5%"
our_markup "80"
consolidator "2%"
agent_comment "1 руб. от всех опубл. тарифов на собств. рейсы CY;"
agent_comment "1 руб. от всех опубл. тарифов на рейсы Interline строго при условии оформления всего маршрута одним билетом и при наличии хотябы одного собств. сегмента CY."
subagent_comment "0,05 руб от всех опубл. тарифов на собств. рейсы CY;"
subagent_comment "0,05 руб от всех опубл. тарифов на рейсы Interline строго при условии оформления всего маршрута одним билетом и при наличии хотябы одного собств. сегмента CY."
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

