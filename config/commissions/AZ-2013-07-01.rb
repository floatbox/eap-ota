carrier "AZ", start_date: "2013-07-01"

rule 1 do
disabled "отмена повышенной! мега срочно"
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "3%"
agent_comment "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent_comment "Если, кратко, то J,E,D,I P,Y,B,M,H,K A,V,T,N,S,L,O"
agent_comment "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent_comment "6%"
subclasses "JEDIPYBMHKAVTNSLO"
routes "US-RU/ALL"
example "svojfk/v jfksvo/m"
example "jfksvo/o"
end

rule 2 do
disabled "отмена повышенной! мега срочно"
ticketing_method "aviacenter"
agent "4%"
subagent "2%"
discount "1%"
agent_comment "4% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
agent_comment "с обязательным наличием в маршруте рейса Москва-Милан AZ565 или AZ56 и обязательным наличием в маршруте рейса Милан-Москва AZ560 и AZ564."
subagent_comment "2% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
classes :economy
check %{ includes(flights.every.full_flight_number, %W(AZ565 AZ56)) and includes(flights.every.full_flight_number, %W(AZ560 AZ564)) }
example "svolin/az565 linsvo/AZ560"
example "svolin/az565 linsvo/AZ560 svocdg"
example "svolin/az565 linsvo/AZ564"
end

rule 3 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "0%"
agent_comment "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent_comment "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
example "mrucdg"
example "mrucdg cdgmru"
end

rule 4 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "0%"
agent_comment "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent_comment "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
example "svocdg cdgsvo/ab"
end

rule 5 do
no_commission
example "svocdg/ab cdgsvo"
end

