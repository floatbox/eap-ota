carrier "DL", start_date: "2013-05-15"

rule 1 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "1.5%"
tour_code "RULAPREM"
comment "FIXME добавить сендвичевы острова и южную георгию"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до South America Tour Code RULAPREM); "
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-AR,BO,BR,VE,GY,CO,PY,PE,SR,UY,FK,GF,CL,EC/OW,RT"
example "svoadz/j adzsvo/c"
end

rule 2 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "1.5%"
tour_code "RUMCBREM"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Caribbean Central Tour Code RUCBPREM); "
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-GY,BB,JM,TT/OW,RT"
example "svotab/j tabsvo/z"
end

rule 3 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "1.5%"
tour_code "RUMXPREM"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Mexico Tour Code RUMXPREM ); "
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-MX/OW,RT"
example "svotam/j tamsvo/z"
end

rule 4 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "1.5%"
tour_code "RUUSPREM"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до USA/CANADA Tour Code RUUSPREM);"
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-US,CA/OW,RT"
example "svoyyz/c yyzsvo/i"
end

rule 5 do
important!
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "3%"
agent_comment "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent_comment "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent_comment "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent_comment "6%"
subclasses "CDZIYBMSHQWKLUTXV"
routes "RU-US/ALL"
example "svojfk/d jfksvo/m"
example "jfksvo/x"
end

rule 6 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "1.5%"
agent_comment "5%"
subagent_comment "3%"
subclasses "SIQKLUT"
routes "SN,GH-US,SN,GH/OW,RT"
example "accjfk/s"
example "zigjfk/i jfkzig/s"
example "accjfk/k jfkacc/k"
end

rule 7 do
important!
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
agent_comment "1%"
subagent_comment "0.5%"
check %{ codeshare? }
example "accjfk/su:dl"
example "zigjfk/su:dl jfkzig/su:dl"
example "accjfk/su:dl jfkacc/su:dl"
example "jfksvo/x/su:dl"
end

rule 8 do
important!
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "1.5%"
agent_comment "5%"
subagent_comment "3%"
subclasses "DIKVTNSL"
check %{ includes_only(country_iatas.first, 'SN GH') and includes_only(country_iatas, 'US SN GH') and includes_only(operating_carrier_iatas, 'AZ') }
example "accjfk/d/az:dl"
example "zigjfk/i/az:dl jfkzig/s/az:dl"
example "accjfk/l/az:dl jfkacc/n/az:dl"
end

rule 9 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
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

rule 10 do
important!
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
agent_comment "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent_comment "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
domestic
example "miadtw dtwmia"
example "miadtw dtwmia/ab"
end

rule 11 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "0.35%"
agent_comment "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent_comment "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
example "cdgsvo/ab"
end

rule 12 do
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

