carrier "U9", start_date: "2013-05-01"

rule 1 do
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
agent_comment "4% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent_comment "3% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
interline :no_codeshare
classes :business
example "svocdg/business cdgsvo/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
comment "бизнес класс отфильтрован правилом #1, поэтому тут классы не указываем"
agent_comment "3% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent_comment "2% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
interline :no_codeshare
example "svocdg svocdg"
example "svocdg svocdg/business"
end

rule 3 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
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

