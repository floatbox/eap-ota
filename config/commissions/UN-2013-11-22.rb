carrier "UN", start_date: "2013-11-22"

rule 1 do
ticketing_method "downtown"
agent "5%"
subagent "4%"
agent_comment "5% американский office-id"
subagent_comment "4% от тарифа на рейсы Перевозчика по всем тарифам классов L,V,X,T,N,I,W."
subclasses "LVXTNIW"
example "AERDME/W DMEAER/W"
example "AERDME/W DMEAER/I"
example "AERDME/N DMEAER/T"
example "AERDME/W DMEAER/W"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "10%"
subagent "8%"
comment "базовое вознаграждение ац для высоких c 22.11"
agent_comment "10% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent_comment "8%"
subclasses "FPRJCADSM"
example "cdgsvo/r svocdg/f"
end

rule 3 do
ticketing_method "aviacenter"
agent "8%"
subagent "6%"
comment "базовое вознаграждение ац c 22.11.2013"
agent_comment "8% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K;"
subagent_comment "6%"
subclasses "YHQBK"
example "cdgsvo/h svocdg/y"
end

rule 4 do
ticketing_method "aviacenter"
agent "6%"
subagent "4%"
agent_comment "6% от тарифа на рейсы Перевозчика по всем тарифам Туристического класса;"
subagent_comment "4% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, W;"
subclasses "FPRJCADSMLVXTNIWYHQBK"
example "cdgsvo/w svocdg/f"
end

rule 5 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
comment "интерлайн c 21.05.2013 (не меняется)"
agent_comment "5% Interline с участком Трансаэро. Без участка UN запрещено."
subagent_comment "3% от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без"
subagent_comment "участка UN"
interline :yes
example "aerdme dmeaer/ab"
end

rule 6 do
important!
ticketing_method "aviacenter"
agent "10%"
subagent "8%"
agent_comment "Для перевозок Interline, при продаже авиаперевозок на бланках с кодом 670 на рейсы авиакомпаний OS, LX, UA, с учаском перевозки на UN, составляет:"
agent_comment "10% от применяемых опубл.тарифов первого, бизнес, экономического и туристического классов"
subagent_comment "8% от применяемых опубл.тарифов первого, бизнес, экономического и туристического классов"
interline :yes
check %{ includes(operating_carrier_iatas, "OS LX UA") }
end

rule 7 do
important!
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
comment "дополнительно: Хьюстон-Сингапур (проверять новый чек)"
agent_comment "9% до особых указаний от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса  между пунктами полетов ОАО «АК «ТРАНСАЭРО»  на территории России и Хьюстоном/Сингапуром (OW, RT)."
subagent_comment "до особых указаний 7% от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса между пунктами полетов ОАО «АК «ТРАНСАЭРО» на территории России и Хьюстоном/Сингапуром (OW, RT)."
check %{ includes(city_iatas, 'HOU SIN') and includes(city_iatas, 'MOW') and includes(country_iatas, 'RU') }
example "svoiws/UN7061"
example "svoaap/UN7061 aapsvo/UN7061"
example "dmesin/UN7062 sindme/UN7062"
end

rule 8 do
no_commission
interline :absent
example "svocdg/lh cdgmad/lh"
end

