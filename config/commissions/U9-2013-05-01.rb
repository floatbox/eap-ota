carrier "U9", start_date: "2013-05-01"

example "svocdg/business cdgsvo/business"
agent "4% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent "3% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
interline :no_codeshare
classes :business
discount "3%"
ticketing_method "aviacenter"
commission "4%/3%"

example "svocdg svocdg"
example "svocdg svocdg/business"
comment "бизнес класс отфильтрован правилом #1, поэтому тут классы не указываем"
agent "3% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent "2% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
interline :no_codeshare
discount "2%"
ticketing_method "aviacenter"
commission "3%/2%"

example "svocdg/ab cdgsvo"
example "svocdg/ab:u9 cdgsvo"
example "svocdg/ab:u9/business"
agent "1% от всех опубл. тарифов на рейсы Interline;"
agent "1% от всех опубл. тарифов на рейсы code-share."
subagent "5 руб от всех опубл. тарифов на рейсы Interline;"
subagent "5 руб от всех опубл. тарифов на рейсы code-share;"
interline :no, :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/5"

