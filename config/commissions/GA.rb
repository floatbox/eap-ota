carrier "GA"

rule 1 do
example "jogsoq soqjog"
agent_comment "5% (Пять) от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
subagent_comment "3% от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
domestic
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 2 do
example "jogjed"
example "jogruh"
agent_comment "от всех опубл. тарифов на собств. рейсы GA на международные перелёты зависит от пункта отправления (см. таблицу ниже):"
agent_comment "ИНДОНЕЗИЯ: 1 РУБ  - если пункт назначения JED/RUH"
subagent_comment "ИНДОНЕЗИЯ: 5 коп. с билета если пункт назначения JED/RUH"
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(JED RUH)) }
agent "1"
subagent "0.05"
end

rule 3 do
example "jogsvo"
agent_comment "ИНДОНЕЗИЯ: 7% - если пункт назначения любой город, кроме JED/RUH"
subagent_comment "ИНДОНЕЗИЯ: 5% от тарифа если пункт назначения любой город, кроме JED/RUH"
discount "5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'ID') and not includes(city_iatas.last, %W(JED RUH)) }
agent "7%"
subagent "5%"
end

rule 4 do
example "joghkg"
example "jogkul"
example "jogsin"
agent_comment "1 РУБ - SIN, 1 РУБ - HKG, 1 РУБ - KUL"
subagent_comment "5 коп. с билета - SIN 5 коп. с билета - HKG 5 коп. с билета - KUL"
important!
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(SIN KUL HKG)) }
agent "1"
subagent "0.05"
end

rule 5 do
example "okojog"
agent_comment "ЯПОНИЯ: 1 РУБ - все тарифы, кроме GA FLEX/PEX FARES"
subagent_comment "ЯПОНИЯ: 5 коп. с билета - все тарифы, кроме GA FLEX/PEX FARES  -"
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') }
agent "1"
subagent "0.05"
end

rule 6 do
example "okojog"
agent_comment "ЯПОНИЯ: 7% - GA FLEX/PEX FARES"
subagent_comment "ЯПОНИЯ: 5% - GA FLEX/PEX FARES"
discount "2.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') }
disabled "no subagent... FLEX PEX?"
agent "7%"
subagent "5%"
end

rule 7 do
example "okoams"
agent_comment "1%  - AMS"
subagent_comment "5 руб. с билета - AMS"
important!
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, 'AMS') }
agent "1%"
subagent "5"
end

rule 8 do
example "okoswp"
example "okomel"
example "okoper"
example "okorse"
agent_comment "5%  - SWP, 5%  - MEL/PER/SYD"
subagent_comment "3% -SWP 3% - MEL/PER/SYD"
important!
discount "3%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SWP MEL PER SYD)) }
agent "5%"
subagent "3%"
end

rule 9 do
example "okossn"
example "okojed"
example "okoruh"
example "okodxb"
agent_comment "7% - SEL, 7% - JED/RUH, 7% - DXB"
subagent_comment "5% - SEL 5% - JED/RUH 5% - DXB"
routes "JP-SEL,JED,RUH,DXB"
important!
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 10 do
example "okobkk"
example "okopek"
example "okosha"
agent_comment "9% - BKK, 9% - BJS/CAN/SHA"
subagent_comment "7% - BKK 7% - BJS/CAN/SHA"
routes "JP-BKK,BJS,CAN,SHA"
important!
discount "7%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

