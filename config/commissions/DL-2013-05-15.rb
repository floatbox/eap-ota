carrier "DL", start_date: "2013-05-15"

rule 1 do
example "svoadz/j adzsvo/c"
comment "FIXME добавить сендвичевы острова и южную георгию"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до South America Tour Code RULAPREM); "
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-AR,BO,BR,VE,GY,CO,PY,PE,SR,UY,FK,GF,CL,EC/OW,RT"
discount "3%"
ticketing_method "downtown"
tour_code "RULAPREM"
agent "5%"
subagent "3%"
end

rule 2 do
example "svotab/j tabsvo/z"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Caribbean Central Tour Code RUCBPREM); "
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-GY,BB,JM,TT/OW,RT"
discount "3%"
ticketing_method "downtown"
tour_code "RUMCBREM"
agent "5%"
subagent "3%"
end

rule 3 do
example "svotam/j tamsvo/z"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Mexico Tour Code RUMXPREM ); "
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-MX/OW,RT"
discount "3%"
ticketing_method "downtown"
tour_code "RUMXPREM"
agent "5%"
subagent "3%"
end

rule 4 do
example "svojfk/d jfksvo/i"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до NYC Tour Code RUNYPREM);"
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-NYC/OW,RT"
discount "1.5%"
ticketing_method "downtown"
tour_code "RUNYPREM"
disabled "DL/AFKL/AZ Comission programm"
agent "5%"
subagent "3%"
end

rule 5 do
example "svoyyz/c yyzsvo/i"
agent_comment "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до USA/CANADA Tour Code RUUSPREM);"
subagent_comment "3%"
subclasses "JCDZI"
routes "MOW-US,CA/OW,RT"
discount "3%"
ticketing_method "downtown"
tour_code "RUUSPREM"
agent "5%"
subagent "3%"
end

rule 6 do
example "svojfk/d jfksvo/m"
example "jfksvo/x"
agent_comment "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent_comment "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent_comment "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent_comment "6%"
subclasses "CDZIYBMSHQWKLUTXV"
routes "RU-US/ALL"
important!
discount "6%"
ticketing_method "downtown"
agent "8%"
subagent "6%"
end

rule 7 do
example "accjfk/s"
example "zigjfk/i jfkzig/s"
example "accjfk/k jfkacc/k"
agent_comment "5%"
subagent_comment "3%"
subclasses "SIQKLUT"
routes "SN,GH-US,SN,GH/OW,RT"
discount "3%"
ticketing_method "downtown"
agent "5%"
subagent "3%"
end

rule 8 do
example "accjfk/su:dl"
example "zigjfk/su:dl jfkzig/su:dl"
example "accjfk/su:dl jfkacc/su:dl"
example "jfksvo/x/su:dl"
agent_comment "1%"
subagent_comment "0.5%"
important!
ticketing_method "aviacenter"
check %{ codeshare? }
agent "1%"
subagent "0.5%"
end

rule 9 do
example "accjfk/d/az:dl"
example "zigjfk/i/az:dl jfkzig/s/az:dl"
example "accjfk/l/az:dl jfkacc/n/az:dl"
agent_comment "5%"
subagent_comment "3%"
subclasses "DIKVTNSL"
important!
discount "3%"
ticketing_method "downtown"
check %{ includes_only(country_iatas.first, 'SN GH') and includes_only(country_iatas, 'US SN GH') and includes_only(operating_carrier_iatas, 'AZ') }
agent "5%"
subagent "3%"
end

rule 10 do
example "okocdg cdgoko/ab"
example "cdgoko"
example "okomia"
agent_comment "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent_comment "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent_comment "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent_comment "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent_comment "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent_comment "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
discount "0%"
ticketing_method "aviacenter"
check %{ includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
agent "1%"
subagent "0.5%"
end

rule 11 do
example "miadtw dtwmia"
example "miadtw dtwmia/ab"
agent_comment "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent_comment "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
important!
domestic
discount "0%"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 12 do
example "cdgsvo/ab"
agent_comment "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent_comment "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
discount "0%"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 13 do
example "EWRDTW DTWYYZ"
comment "ньюйорк - детройт - торонто"
agent_comment "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent_comment "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :no, :yes
routes "PR,US,VI,CA..."
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

