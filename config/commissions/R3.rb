carrier "R3"

rule 1 do
example "svocdg cdgsvo"
agent_comment "6 % от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
subagent_comment "4% от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
discount "4%"
ticketing_method "aviacenter"
agent "6%"
subagent "4%"
end

rule 2 do
example "ykscdg/ab cdgyks"
agent_comment "4 % от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами Авиакомпании."
subagent_comment "3% от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами"
interline :yes
discount "3%"
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
end

