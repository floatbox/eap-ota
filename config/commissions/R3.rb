carrier "R3"

example "svocdg cdgsvo"
agent "6 % от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
subagent "4% от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
discount "4%"
ticketing_method "aviacenter"
commission "6%/4%"

example "ykscdg/ab cdgyks"
agent "4 % от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами Авиакомпании."
subagent "3% от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами"
interline :yes
discount "3%"
ticketing_method "aviacenter"
commission "4%/3%"

