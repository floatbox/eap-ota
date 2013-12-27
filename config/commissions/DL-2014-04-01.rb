carrier "DL", start_date: "2014-04-01"

rule 1 do
disabled "dtt disabled"
ticketing_method "downtown"
agent "8%"
subagent "6%"
agent_comment "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent_comment "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent_comment "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent_comment "6%"
subclasses "CDZIYBMSHQWKLUTXV"
routes "RU...US/ALL"
example "svojfk/d jfksvo/m"
example "jfksvo/x"
end

rule 2 do
disabled "продаем по dtt"
ticketing_method "aviacenter"
agent "4%"
subagent "2%"
agent_comment "4% (2%) (2%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ;"
subagent_comment "4% (2%) (2%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ;"
subclasses "JCDZI"
routes "MOW..."
example "svojfk/f"
example "svojfk/c jfksvo/d"
end

rule 3 do
disabled "включил dtt"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
agent_comment "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent_comment "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent_comment "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent_comment "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent_comment "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent_comment "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
check %{ includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
example "okocdg cdgoko/ab"
example "cdgoko"
example "okomia"
end

rule 4 do
important!
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
agent_comment "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent_comment "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
domestic
example "miadtw dtwmia"
example "miadtw dtwmia/ab"
end

rule 5 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
agent_comment "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent_comment "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
example "cdgsvo/ab"
end

rule 6 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
comment "ньюйорк - детройт - торонто"
agent_comment "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent_comment "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :no, :yes
routes "PR,US,VI,CA..."
example "EWRDTW DTWYYZ"
end

