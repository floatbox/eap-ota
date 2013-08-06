carrier "AZ", start_date: "2013-07-01"

rule 1 do
example "svojfk/v jfksvo/m"
example "jfksvo/o"
agent_comment "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent_comment "Если, кратко, то J,E,D,I P,Y,B,M,H,K A,V,T,N,S,L,O"
agent_comment "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent_comment "6%"
subclasses "JEDIPYBMHKAVTNSLO"
routes "US-RU/ALL"
discount "3%"
ticketing_method "downtown"
disabled "отмена повышенной! мега срочно"
agent "8%"
subagent "6%"
end

rule 2 do
example "svolin/az565 linsvo/AZ560"
example "svolin/az565 linsvo/AZ560 svocdg"
example "svolin/az565 linsvo/AZ564"
agent_comment "4% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
agent_comment "с обязательным наличием в маршруте рейса Москва-Милан AZ565 или AZ56 и обязательным наличием в маршруте рейса Милан-Москва AZ560 и AZ564."
subagent_comment "2% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
classes :economy
discount "1%"
ticketing_method "aviacenter"
check %{ includes(flights.every.full_flight_number, %W(AZ565 AZ56)) and includes(flights.every.full_flight_number, %W(AZ560 AZ564)) }
disabled "отмена повышенной! мега срочно"
agent "4%"
subagent "2%"
end

rule 3 do
example "mrucdg"
example "mrucdg cdgmru"
agent_comment "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent_comment "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
our_markup "0%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 4 do
example "svocdg cdgsvo/ab"
agent_comment "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent_comment "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
our_markup "0%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 5 do
example "svocdg/ab cdgsvo"
no_commission
end

