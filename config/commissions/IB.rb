carrier "IB"

rule 1 do
example "svocdg cdgsvo"
agent_comment "1 руб. с билета на рейсы IB. (Билеты Interline под кодом IB могут быть выписаны только в случае существования опубл. тарифов и только при условии, что IB выполняет первый рейс маршрута."
subagent_comment "50 коп. с билета на рейсы IB"
consolidator "0%"
our_markup "0%"
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
end

