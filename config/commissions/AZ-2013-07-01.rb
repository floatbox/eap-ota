carrier "AZ", start_date: "2013-07-01"

example "svojfk/v jfksvo/m"
example "jfksvo/o"
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то J,E,D,I P,Y,B,M,H,K A,V,T,N,S,L,O"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "JEDIPYBMHKAVTNSLO"
routes "US-RU/ALL"
discount "3%"
ticketing_method "downtown"
disabled "отмена повышенной! мега срочно"
commission "8%/6%"

example "svolin/az565 linsvo/AZ560"
example "svolin/az565 linsvo/AZ560 svocdg"
example "svolin/az565 linsvo/AZ564"
agent "4% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
agent "с обязательным наличием в маршруте рейса Москва-Милан AZ565 или AZ56 и обязательным наличием в маршруте рейса Милан-Москва AZ560 и AZ564."
subagent "2% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
classes :economy
discount "1%"
ticketing_method "aviacenter"
check %{ includes(flights.every.full_flight_number, %W(AZ565 AZ56)) and includes(flights.every.full_flight_number, %W(AZ560 AZ564)) }
disabled "отмена повышенной! мега срочно"
commission "4%/2%"

example "mrucdg"
example "mrucdg cdgmru"
agent "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
our_markup "0%"
ticketing_method "aviacenter"
commission "1eur/5"

example "svocdg cdgsvo/ab"
agent "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
our_markup "0%"
ticketing_method "aviacenter"
commission "1eur/5"

example "svocdg/ab cdgsvo"
no_commission

