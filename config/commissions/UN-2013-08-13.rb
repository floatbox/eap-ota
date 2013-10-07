carrier "UN", start_date: "2013-08-13"

rule 1 do
ticketing_method "downtown"
agent "5%"
subagent "4%"
discount "2.8%"
agent_comment "5% американский office-id"
subagent_comment "4% от тарифа на рейсы Перевозчика по всем тарифам классов L,V,X,T,N,I,W."
subclasses "LVXTNIW"
example "AERDME/W DMEAER/W"
example "AERDME/W DMEAER/I"
example "AERDME/N DMEAER/T"
example "AERDME/W DMEAER/W"
end

rule 2 do
ticketing_method "aviacenter"
agent "10%"
subagent "8%"
discount "2.4%"
comment "ДОПОЛНИТЕЛЬНОЕ ВОЗНАГРАЖДЕНИЕ на период c 13.08.13г. по 27.10.13г."
agent_comment "7% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent_comment "5%"
subclasses "FPRJCADSM"
routes "RU...MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "LED-HER,RHO,PED,ATH,NBE/ALL"
example "dmebkk/r bkkdme/f"
end

rule 3 do
ticketing_method "aviacenter"
agent "8%"
subagent "6%"
discount "1.8%"
comment "ДОПОЛНИТЕЛЬНОЕ ВОЗНАГРАЖДЕНИЕ на период c 13.08.13г. по 27.10.13г."
agent_comment "C 21.06.13г. 5% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K;"
subagent_comment "3%"
subclasses "YHQBK"
routes "RU...MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "LED-HER,RHO,PED,ATH,NBE/ALL"
example "dmebkk/h bkkdme/y"
end

rule 4 do
ticketing_method "aviacenter"
agent "6%"
subagent "4%"
discount "1.2%"
comment "ДОПОЛНИТЕЛЬНОЕ ВОЗНАГРАЖДЕНИЕ на период c 13.08.13г. по 27.10.13г."
agent_comment "3% от тарифа на рейсы Перевозчика по всем тарифам Туристического класса;"
subagent_comment "1% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U;"
subclasses "GU"
routes "RU...MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "LED-HER,RHO,PED,ATH,NBE/ALL"
example "dmebkk/g bkkdme/u"
end

rule 5 do
ticketing_method "aviacenter"
agent "8%"
subagent "6%"
discount "1.8%"
comment "ДОПОЛНИТЕЛЬНОЕ ВОЗНАГРАЖДЕНИЕ на период c 13.08.13г. по 27.10.13г."
agent_comment "5% Interline с участком Трансаэро. Без участка UN запрещено."
subagent_comment "3% от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без"
subagent_comment "участка UN"
interline :yes
routes "RU...MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "MOW-HRG,SSH,NBE,AYT,DLM,IST,BKK,HKT,SGN,MLE,VRA,CUN,PUJ,ALC,BCN,AGP,MAD,TCI,RMI,PED,PFO,HER,RHO/ALL", "LED-HER,RHO,PED,ATH,NBE/ALL"
example "dmebkk bkkdme/ab"
end

rule 6 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "1.5%"
agent_comment "7% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent_comment "5%"
subclasses "FPRJCADSM"
example "cdgsvo/r svocdg/f"
end

rule 7 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "0.9%"
agent_comment "C 21.06.13г. 5% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K;"
subagent_comment "3%"
subclasses "YHQBK"
example "cdgsvo/h svocdg/y"
end

rule 8 do
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
discount "0.3%"
agent_comment "3% от тарифа на рейсы Перевозчика по всем тарифам Туристического класса;"
subagent_comment "1% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U;"
subclasses "GU"
example "cdgsvo/g svocdg/u"
end

rule 9 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "0.9%"
agent_comment "5% Interline с участком Трансаэро. Без участка UN запрещено."
subagent_comment "3% от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без"
subagent_comment "участка UN"
interline :yes
example "aerdme dmeaer/ab"
end

rule 10 do
important!
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "2.1%"
comment "дополнительно: Хьюстон-Сингапур (проверять новый чек)"
agent_comment "9% до особых указаний от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса  между пунктами полетов ОАО «АК «ТРАНСАЭРО»  на территории России и Хьюстоном/Сингапуром (OW, RT)."
subagent_comment "до особых указаний 7% от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса между пунктами полетов ОАО «АК «ТРАНСАЭРО» на территории России и Хьюстоном/Сингапуром (OW, RT)."
check %{ includes(city_iatas, 'HOU SIN') and includes(city_iatas, 'MOW') and includes(country_iatas, 'RU') }
example "svoiws/UN7061"
example "svoaap/UN7061 aapsvo/UN7061"
example "dmesin/UN7062 sindme/UN7062"
end

rule 11 do
no_commission "12%/10%"
important!
ticketing_method "aviacenter"
discount "4%"
comment "Пекин прямые из Москвы и сквозные через Москву из RU UA KZ UZ AM — через dtt"
agent_comment "12% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
agent_comment "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent_comment "10% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
subagent_comment "10% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
routes "RU,UA,KZ,UZ,AM-MOW-BJS/ALL", "MOW-BJS/ALL"
example "kbpsvo svopek"
example "tsedme dmepek pekdme dmetse"
end

rule 12 do
important!
ticketing_method "downtown"
agent "12%"
subagent "11%"
discount "7.7%"
comment "Майами/Нью-Йорк прямые из Москвы и сквозные через Москву из RU UA KZ UZ AM — через dtt"
comment "FIX кривой и не полный чек"
agent_comment "12% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
agent_comment "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent_comment "11% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
subagent_comment "11% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
routes "RU,UA,KZ,UZ,AM-MOW-NYC,MIA,LAX/ALL", "MOW-NYC,MIA,LAX/ALL"
example "kbpsvo svojfk"
example "tsedme dmejfk jfkdme dmetse"
end

rule 13 do
no_commission
interline :absent
example "svocdg/lh cdgmad/lh"
end

