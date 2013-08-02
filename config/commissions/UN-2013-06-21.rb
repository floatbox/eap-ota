carrier "UN", start_date: "2013-06-21"

example "AERDME/W DMEAER/W"
example "AERDME/W DMEAER/I"
example "AERDME/N DMEAER/T"
example "AERDME/W DMEAER/W"
agent "5% американский office-id"
subagent "4% от тарифа на рейсы Перевозчика по всем тарифам классов L,V,X,T,N,I,W."
subclasses "LVXTNIW"
discount "3%"
ticketing_method "downtown"
commission "5%/4%"

example "cdgsvo/r svocdg/f"
comment "базовое вознаграждение ац для высоких c 21.06"
agent "7% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent "5%"
subclasses "FPRJCADSM"
important!
discount "4%"
ticketing_method "aviacenter"
commission "7%/5%"

example "cdgsvo/h svocdg/y"
comment "базовое вознаграждение ац c 21.06.2013"
agent "C 21.06.13г. 5% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K;"
subagent "3%"
subclasses "YHQBK"
discount "2%"
ticketing_method "aviacenter"
commission "5%/3%"

example "cdgsvo/g svocdg/u"
comment "говноклассы с 21.06"
agent "3% от тарифа на рейсы Перевозчика по всем тарифам Туристического класса;"
subagent "1% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U;"
subclasses "GU"
discount "0%"
ticketing_method "aviacenter"
commission "3%/1%"

example "aerdme dmeaer/ab"
comment "интерлайн c 21.05.2013 (не меняется)"
agent "5% Interline с участком Трансаэро. Без участка UN запрещено."
subagent "3% от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без"
subagent "участка UN"
interline :yes
discount "2%"
ticketing_method "aviacenter"
commission "5%/3%"

example "svoiws/UN7061"
example "svoaap/UN7061 aapsvo/UN7061"
example "dmesin/UN7062 sindme/UN7062"
comment "дополнительно: Хьюстон-Сингапур (проверять новый чек)"
agent "9% до особых указаний от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса  между пунктами полетов ОАО «АК «ТРАНСАЭРО»  на территории России и Хьюстоном/Сингапуром (OW, RT)."
subagent "до особых указаний 7% от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса между пунктами полетов ОАО «АК «ТРАНСАЭРО» на территории России и Хьюстоном/Сингапуром (OW, RT)."
important!
discount "5%"
ticketing_method "aviacenter"
check %{ includes(city_iatas, 'HOU SIN') and includes(city_iatas, 'MOW') and includes(country_iatas, 'RU') }
commission "9%/7%"

example "kbpsvo svopek"
example "tsedme dmepek pekdme dmetse"
comment "Пекин прямые из Москвы и сквозные через Москву из RU UA KZ UZ AM — через dtt"
agent "12% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "10% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
subagent "10% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
routes "RU,UA,KZ,UZ,AM-MOW-BJS/ALL", "MOW-BJS/ALL"
important!
discount "4%"
ticketing_method "aviacenter"
no_commission "12%/10%"

example "kbpsvo svojfk"
example "tsedme dmejfk jfkdme dmetse"
comment "Майами/Нью-Йорк прямые из Москвы и сквозные через Москву из RU UA KZ UZ AM — через dtt"
comment "FIX кривой и не полный чек"
agent "12% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "11% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
subagent "11% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
routes "RU,UA,KZ,UZ,AM-MOW-NYC,MIA,LAX/ALL", "MOW-NYC,MIA,LAX/ALL"
important!
discount "9%"
ticketing_method "downtown"
commission "12%/11%"

example "svocdg/lh cdgmad/lh"
interline :absent
no_commission

