carrier "AZ", start_date: "2013-10-01"

rule 1 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
our_markup "150"
agent_comment "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent_comment "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
example "mrucdg"
example "mrucdg cdgmru"
end

rule 2 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
our_markup "150"
agent_comment "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent_comment "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
example "svocdg cdgsvo/ab"
end

rule 3 do
no_commission
example "svocdg/ab cdgsvo"
end

