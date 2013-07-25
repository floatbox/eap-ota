carrier "NN"

example "svocdg/c cdgsvo/d"
comment "это у NN — бизнес-класс"
agent "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subclasses "CD"
discount "1.75%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg cdgsvo"
agent "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
discount "1.75%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg/ab cdgsvo"
agent "Интерлайн не прописан"
subagent "Интерлайн не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0"

