carrier "NN"

rule 1 do
example "svocdg/c cdgsvo/d"
comment "это у NN — бизнес-класс"
agent_comment "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent_comment "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subclasses "CD"
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 2 do
example "svocdg cdgsvo"
agent_comment "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent_comment "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 3 do
example "svocdg/ab cdgsvo"
agent_comment "Интерлайн не прописан"
subagent_comment "Интерлайн не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0"
end

