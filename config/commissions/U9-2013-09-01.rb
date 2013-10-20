carrier "U9", start_date: "2013-09-01"

rule 1 do
ticketing_method "aviacenter"
agent "2%"
subagent "1%"
discount "1%"
agent_comment "2% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent_comment "1% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
interline :no_codeshare
classes :business
example "svocdg/business cdgsvo/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "1.5%"
our_markup "80"
consolidator "2%"
comment "бизнес класс отфильтрован правилом #1, поэтому тут классы не указываем"
agent_comment "1% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent_comment "5 р. от опубл. тарифов на собств. рейсы U9 Эконом класса;"
interline :no_codeshare
example "svocdg svocdg"
example "svocdg svocdg/business"
end

rule 3 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "1.5%"
our_markup "80"
consolidator "2%"
agent_comment "1% от всех опубл. тарифов на рейсы Interline;"
agent_comment "1% от всех опубл. тарифов на рейсы code-share."
subagent_comment "5 руб от всех опубл. тарифов на рейсы Interline;"
subagent_comment "5 руб от всех опубл. тарифов на рейсы code-share;"
interline :no, :yes
example "svocdg/ab cdgsvo"
example "svocdg/ab:u9 cdgsvo"
example "svocdg/ab:u9/business"
end

