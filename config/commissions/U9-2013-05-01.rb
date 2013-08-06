carrier "U9", start_date: "2013-05-01"

rule 1 do
example "svocdg/business cdgsvo/business"
agent_comment "4% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent_comment "3% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
interline :no_codeshare
classes :business
discount "3%"
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
end

rule 2 do
example "svocdg svocdg"
example "svocdg svocdg/business"
comment "бизнес класс отфильтрован правилом #1, поэтому тут классы не указываем"
agent_comment "3% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent_comment "2% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
interline :no_codeshare
discount "2%"
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
end

rule 3 do
example "svocdg/ab cdgsvo"
example "svocdg/ab:u9 cdgsvo"
example "svocdg/ab:u9/business"
agent_comment "1% от всех опубл. тарифов на рейсы Interline;"
agent_comment "1% от всех опубл. тарифов на рейсы code-share."
subagent_comment "5 руб от всех опубл. тарифов на рейсы Interline;"
subagent_comment "5 руб от всех опубл. тарифов на рейсы code-share;"
interline :no, :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

