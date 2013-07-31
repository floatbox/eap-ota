carrier "U9", start_date: "2013-05-01"

example "svocdg/business cdgsvo/business"
agent "4% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent "3% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
classes :business
discount "2.5%"
ticketing_method "aviacenter"
commission "4%/3%"

example "svocdg/economy svocdg/economy"
agent "3% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent "2% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
classes :economy
discount "1%"
ticketing_method "aviacenter"
commission "3%/2%"

example "svocdg/ab cdgsvo"
agent "1% от всех опубл. тарифов на рейсы Interline;"
subagent "5 руб от всех опубл. тарифов на рейсы Interline;"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/5"

agent "1% от всех опубл. тарифов на рейсы code-share."
subagent "5 руб от всех опубл. тарифов на рейсы code-share;"
consolidator "2%"
ticketing_method "aviacenter"
not_implemented "не умеем определять code-share"
commission "1%/5"

