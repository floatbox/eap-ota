carrier "DL", start_date: "2013-05-15"

example "svoadz/j adzsvo/c"
comment "FIXME добавить сендвичевы острова и южную георгию"
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до South America Tour Code RULAPREM); "
subagent "3%"
subclasses "JCDZI"
routes "MOW-AR,BO,BR,VE,GY,CO,PY,PE,SR,UY,FK,GF,CL,EC/OW,RT"
discount "2%"
ticketing_method "downtown"
tour_code "RULAPREM"
commission "5%/3%"

example "svotab/j tabsvo/z"
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Caribbean Central Tour Code RUCBPREM); "
subagent "3%"
subclasses "JCDZI"
routes "MOW-GY,BB,JM,TT/OW,RT"
discount "2%"
ticketing_method "downtown"
tour_code "RUMCBREM"
commission "5%/3%"

example "svotam/j tamsvo/z"
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Mexico Tour Code RUMXPREM ); "
subagent "3%"
subclasses "JCDZI"
routes "MOW-MX/OW,RT"
discount "2%"
ticketing_method "downtown"
tour_code "RUMXPREM"
commission "5%/3%"

example "svojfk/d jfksvo/i"
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до NYC Tour Code RUNYPREM);"
subagent "3%"
subclasses "JCDZI"
routes "MOW-NYC/OW,RT"
discount "1.5%"
ticketing_method "downtown"
tour_code "RUNYPREM"
disabled "DL/AFKL/AZ Comission programm"
commission "5%/3%"

example "svoyyz/c yyzsvo/i"
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до USA/CANADA Tour Code RUUSPREM);"
subagent "3%"
subclasses "JCDZI"
routes "MOW-US,CA/OW,RT"
discount "2%"
ticketing_method "downtown"
tour_code "RUUSPREM"
commission "5%/3%"

example "svojfk/d jfksvo/m"
example "jfksvo/x"
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIYBMSHQWKLUTXV"
routes "RU-US/ALL"
important!
discount "4.5%"
ticketing_method "downtown"
commission "8%/6%"

example "accjfk/s"
example "zigjfk/i jfkzig/s"
example "accjfk/k jfkacc/k"
agent "5%"
subagent "3%"
subclasses "SIQKLUT"
routes "SN,GH-US,SN,GH/OW,RT"
discount "2%"
ticketing_method "downtown"
commission "5%/3%"

example "accjfk/su:dl"
example "zigjfk/su:dl jfkzig/su:dl"
example "accjfk/su:dl jfkacc/su:dl"
example "jfksvo/x/su:dl"
agent "1%"
subagent "0.5%"
important!
ticketing_method "aviacenter"
check %{ codeshare? }
commission "1%/0.5%"

example "accjfk/d/az:dl"
example "zigjfk/i/az:dl jfkzig/s/az:dl"
example "accjfk/l/az:dl jfkacc/n/az:dl"
agent "5%"
subagent "3%"
subclasses "DIKVTNSL"
important!
discount "2%"
ticketing_method "downtown"
check %{ includes_only(country_iatas.first, 'SN GH') and includes_only(country_iatas, 'US SN GH') and includes_only(operating_carrier_iatas, 'AZ') }
commission "5%/3%"

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
discount "0%"
ticketing_method "aviacenter"
check %{ includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
commission "1%/0.5%"

example "miadtw dtwmia"
example "miadtw dtwmia/ab"
agent "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
important!
domestic
discount "0%"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "cdgsvo/ab"
agent "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
discount "0%"
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

