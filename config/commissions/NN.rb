carrier "NN"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "7%"
comment "это у NN — бизнес-класс"
agent_comment "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent_comment "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subclasses "CD"
example "svocdg/c cdgsvo/d"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "7%"
agent_comment "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent_comment "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
example "svocdg cdgsvo"
end

rule 3 do
ticketing_method "aviacenter"
agent "1"
subagent "0"
discount "4.5%"
consolidator "2%"
agent_comment "Интерлайн не прописан"
subagent_comment "Интерлайн не прописан"
interline :unconfirmed
example "svocdg/ab cdgsvo"
end

