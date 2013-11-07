carrier "OK", start_date: "2013-11-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "0.9%"
agent_comment "С 01.11.13г. по 31.03.14г. 5% (3%) от опубл. тарифов на рейсы с вылетом из ниже перечисленных городов РФ (включая рейсы code-share)."
agent_comment "Москва  -  все перевозки;"
agent_comment "Екатеринбург - все перевозки;"
agent_comment "Нижний Новгорода - все перевозки;"
agent_comment "Санкт Петербург - Все перевозки;"
agent_comment "Пермь - Только транзитные перевозки;"
agent_comment "Ростов - Только транзитные перевозки;"
agent_comment "Самара - Только транзитные перевозки;"
agent_comment "Уфа - Только транзитные перевозки;"
routes "MOW,SVX,GOJ,LED..."
example "svocdg"
example "svxcdg cdgsvx"
example "gojcdg"
example "ledcdg"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "0.9%"
comment "Копия для ловли код-шера"
agent_comment "С 01.11.13г. по 31.03.14г. 5% (3%) от опубл. тарифов на рейсы с вылетом из ниже перечисленных городов РФ (включая рейсы code-share)."
agent_comment "Москва  -  все перевозки;"
agent_comment "Екатеринбург - все перевозки;"
agent_comment "Нижний Новгорода - все перевозки;"
agent_comment "Санкт Петербург - Все перевозки;"
agent_comment "Пермь - Только транзитные перевозки;"
agent_comment "Ростов - Только транзитные перевозки;"
agent_comment "Самара - Только транзитные перевозки;"
agent_comment "Уфа - Только транзитные перевозки;"
routes "MOW,SVX,GOJ,LED..."
check %{ codeshare? }
example "svocdg/ab:ok"
example "svxcdg/ab:ok cdgsvx"
example "gojcdg/ab:ok"
example "ledcdg/ab:ok"
end

rule 3 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.15%"
agent_comment "1% от опубл. тарифов на собств.рейсы OK;"
agent_comment "1% от опубл. тарифов на рейсы Interline, если один из сегментов выполнен под кодом OK."
subagent_comment "0.5%"
interline :no, :yes
example "ovbcdg"
example "cdgovb ovbcdg/ab"
end

