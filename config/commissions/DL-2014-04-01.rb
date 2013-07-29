carrier "DL", start_date: "2014-04-01"

example "svojfk/d jfksvo/m"
example "jfksvo/x"
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIYBMSHQWKLUTXV"
routes "RU-US/ALL"
discount "3%"
ticketing_method "downtown"
commission "8%/6%"

example "svojfk/f"
example "svojfk/c jfksvo/d"
agent "4% (2%) (2%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ;"
subagent "4% (2%) (2%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ;"
subclasses "JCDZI"
routes "MOW..."
discount "1%"
ticketing_method "aviacenter"
disabled "продаем по dtt"
commission "4%/2%"

example "okocdg cdgoko/ab"
example "cdgoko"
example "okomia"
agent "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
discount "0.25%"
ticketing_method "aviacenter"
check %{ includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
disabled "включил dtt"
commission "1%/0.5%"

example "miadtw dtwmia"
example "miadtw dtwmia/ab"
agent "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
important!
domestic
discount "0.25%"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "cdgsvo/ab"
agent "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
discount "0.25%"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "EWRDTW DTWYYZ"
comment "ньюйорк - детройт - торонто"
agent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :no, :yes
routes "PR,US,VI,CA..."
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

