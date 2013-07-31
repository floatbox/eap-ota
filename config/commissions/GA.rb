carrier "GA"

example "jogsoq soqjog"
agent "5% (Пять) от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
subagent "3% от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
domestic
discount "3%"
ticketing_method "aviacenter"
commission "5%/3%"

example "jogjed"
example "jogruh"
agent "от всех опубл. тарифов на собств. рейсы GA на международные перелёты зависит от пункта отправления (см. таблицу ниже):"
agent "ИНДОНЕЗИЯ: 1 РУБ  - если пункт назначения JED/RUH"
subagent "ИНДОНЕЗИЯ: 5 коп. с билета если пункт назначения JED/RUH"
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(JED RUH)) }
commission "1/0.05"

example "jogsvo"
agent "ИНДОНЕЗИЯ: 7% - если пункт назначения любой город, кроме JED/RUH"
subagent "ИНДОНЕЗИЯ: 5% от тарифа если пункт назначения любой город, кроме JED/RUH"
discount "5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'ID') and not includes(city_iatas.last, %W(JED RUH)) }
commission "7%/5%"

example "joghkg"
example "jogkul"
example "jogsin"
agent "1 РУБ - SIN, 1 РУБ - HKG, 1 РУБ - KUL"
subagent "5 коп. с билета - SIN 5 коп. с билета - HKG 5 коп. с билета - KUL"
important!
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(SIN KUL HKG)) }
commission "1/0.05"

example "okojog"
agent "ЯПОНИЯ: 1 РУБ - все тарифы, кроме GA FLEX/PEX FARES"
subagent "ЯПОНИЯ: 5 коп. с билета - все тарифы, кроме GA FLEX/PEX FARES  -"
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') }
commission "1/0.05"

example "okojog"
agent "ЯПОНИЯ: 7% - GA FLEX/PEX FARES"
subagent "ЯПОНИЯ: 5% - GA FLEX/PEX FARES"
discount "2.5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') }
disabled "no subagent... FLEX PEX?"
commission "7%/5%"

example "okoams"
agent "1%  - AMS"
subagent "5 руб. с билета - AMS"
important!
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, 'AMS') }
commission "1%/5"

example "okoswp"
example "okomel"
example "okoper"
example "okorse"
agent "5%  - SWP, 5%  - MEL/PER/SYD"
subagent "3% -SWP 3% - MEL/PER/SYD"
important!
discount "3%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SWP MEL PER SYD)) }
commission "5%/3%"

example "okossn"
example "okojed"
example "okoruh"
example "okodxb"
agent "7% - SEL, 7% - JED/RUH, 7% - DXB"
subagent "5% - SEL 5% - JED/RUH 5% - DXB"
routes "JP-SEL,JED,RUH,DXB"
important!
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "okobkk"
example "okopek"
example "okosha"
agent "9% - BKK, 9% - BJS/CAN/SHA"
subagent "7% - BKK 7% - BJS/CAN/SHA"
routes "JP-BKK,BJS,CAN,SHA"
important!
discount "7%"
ticketing_method "aviacenter"
commission "9%/7%"

