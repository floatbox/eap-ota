carrier "GA"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "5% (Пять) от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
subagent_comment "3% от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
domestic
example "jogsoq soqjog"
end

rule 2 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2%"
consolidator "2%"
agent_comment "от всех опубл. тарифов на собств. рейсы GA на международные перелёты зависит от пункта отправления (см. таблицу ниже):"
agent_comment "ИНДОНЕЗИЯ: 1 РУБ  - если пункт назначения JED/RUH"
subagent_comment "ИНДОНЕЗИЯ: 5 коп. с билета если пункт назначения JED/RUH"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(JED RUH)) }
example "jogjed"
example "jogruh"
end

rule 3 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "ИНДОНЕЗИЯ: 7% - если пункт назначения любой город, кроме JED/RUH"
subagent_comment "ИНДОНЕЗИЯ: 5% от тарифа если пункт назначения любой город, кроме JED/RUH"
check %{ includes(country_iatas.first, 'ID') and not includes(city_iatas.last, %W(JED RUH)) }
example "jogsvo"
end

rule 4 do
important!
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2%"
consolidator "2%"
agent_comment "1 РУБ - SIN, 1 РУБ - HKG, 1 РУБ - KUL"
subagent_comment "5 коп. с билета - SIN 5 коп. с билета - HKG 5 коп. с билета - KUL"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(SIN KUL HKG)) }
example "joghkg"
example "jogkul"
example "jogsin"
end

rule 5 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2%"
consolidator "2%"
agent_comment "ЯПОНИЯ: 1 РУБ - все тарифы, кроме GA FLEX/PEX FARES"
subagent_comment "ЯПОНИЯ: 5 коп. с билета - все тарифы, кроме GA FLEX/PEX FARES  -"
check %{ includes(country_iatas.first, 'JP') }
example "okojog"
end

rule 6 do
not_implemented "FLEX PEX?"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "ЯПОНИЯ: 7% - GA FLEX/PEX FARES"
subagent_comment "ЯПОНИЯ: 5% - GA FLEX/PEX FARES"
check %{ includes(country_iatas.first, 'JP') }
example "okojog"
end

rule 7 do
important!
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "2%"
consolidator "2%"
agent_comment "1%  - AMS"
subagent_comment "5 руб. с билета - AMS"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, 'AMS') }
example "okoams"
end

rule 8 do
important!
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "5%  - SWP, 5%  - MEL/PER/SYD"
subagent_comment "3% -SWP 3% - MEL/PER/SYD"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SWP MEL PER SYD)) }
example "okoswp"
example "okomel"
example "okoper"
example "okorse"
end

rule 9 do
important!
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7% - SEL, 7% - JED/RUH, 7% - DXB"
subagent_comment "5% - SEL 5% - JED/RUH 5% - DXB"
routes "JP-SEL,JED,RUH,DXB"
example "okossn"
example "okojed"
example "okoruh"
example "okodxb"
end

rule 10 do
important!
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "8%"
agent_comment "9% - BKK, 9% - BJS/CAN/SHA"
subagent_comment "7% - BKK 7% - BJS/CAN/SHA"
routes "JP-BKK,BJS,CAN,SHA"
example "okobkk"
example "okopek"
example "okosha"
end

