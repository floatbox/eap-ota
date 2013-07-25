carrier "7D", start_date: "2011-04-11"

example "svocdg"
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на собств. рейсы 7D;"
discount "1.75%"
ticketing_method "aviacenter"
disabled "out of BSP"
commission "5%/3.5%"

example "cdgsvo svocdg/ab"
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на интерлайн-перевозки как с участием собственных, так и без участия собственных рейсов (только рейсы интерлайн-партнёров) авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на рейсы Interline с уч. собств. рейсов 7D;"
interline :yes, :absent
discount "1.75%"
ticketing_method "aviacenter"
disabled "out of BSP"
commission "5%/3.5%"

