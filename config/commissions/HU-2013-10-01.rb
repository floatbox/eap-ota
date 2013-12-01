carrier "HU", start_date: "2013-10-01"

rule 1 do
ticketing_method "aviacenter"
agent "20%"
subagent "18%"
discount "21%"
comment "Повышенные комиссии из Москвы в Китай"
agent_comment "20% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "18% от опубл.тарифов по кл. С на собств.рейсы HU по маршруту MOW-CHINA или MOW-CHINA-MOW"
subclasses "C"
routes "MOW-CN/OW,RT"
example "svopek/c"
example "svopek/c peksvo/c"
end

rule 2 do
ticketing_method "aviacenter"
agent "15%"
subagent "13%"
discount "16%"
comment "Повышенные комиссии из Москвы в Китай"
agent_comment "15% от опубл.тарифов по кл. D,I на собств.рейсы HU по маршруту MOW-CHINA или MOW-CHINA-MOW"
subagent_comment "13% от опубл.тарифов по кл. D,I на собств.рейсы HU по маршруту MOW-CHINA или MOW-CHINA-MOW"
subclasses "DI"
routes "MOW-CN/OW,RT"
example "svopek/d"
example "svopek/i"
example "svopek/d peksvo/i"
end

rule 3 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
comment "Повышенные комиссии из Москвы в Китай"
agent_comment "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "Z"
routes "MOW-CN/OW,RT"
example "svopek/z"
example "svopek/z peksvo/z"
end

rule 4 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
comment "Повышенные комиссии из Москвы в Китай"
agent_comment "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
classes :economy
routes "MOW-CN/OW,RT"
example "svopek/economy"
example "svopek/economy peksvo/economy"
end

rule 5 do
ticketing_method "aviacenter"
agent "15%"
subagent "13%"
discount "16%"
comment "Повышенные комиссии из Питера в Китай"
agent_comment "15% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent_comment "13% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subclasses "CD"
routes "LED-CN/OW,RT"
example "ledpek/c"
example "ledpek/c pekled/d"
end

rule 6 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
comment "Повышенные комиссии из Питера в Китай"
agent_comment "9% от опубл.тарифов по классам I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent_comment "7% от опубл.тарифов по Эконом классам на собств.рейсы HU по маршруту LED-CHINA или LED- CHINA-LED"
subclasses "IZ"
routes "LED-CN/OW,RT"
example "ledpek/i"
example "ledpek/i pekled/z"
end

rule 7 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
comment "Повышенные комиссии из Питера в Китай"
agent_comment "9% от опубл.тарифов по классам I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent_comment "7% от опубл.тарифов по Эконом классам на собств.рейсы HU по маршруту LED-CHINA или LED- CHINA-LED"
classes :economy
routes "LED-CN/OW,RT"
example "ledpek/economy"
example "ledpek/economy pekled/economy"
end

rule 8 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
comment "Повышенные комиссии из Новосибирска, Иркутска, Красноярска в Китай"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subclasses "CDIZ"
routes "OVB,IKT,KJA-CN/OW,RT"
example "ovbpek/c"
example "ovbpek/i pekovb/z"
example "iktpek/d"
example "iktpek/i pekikt/z"
example "kjapek/c"
example "kjapek/i pekkja/z"
end

rule 9 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
comment "Повышенные комиссии из Новосибирска, Иркутска, Красноярска в Китай"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
classes :economy
routes "OVB,IKT,KJA-CN/OW,RT"
example "ovbpek/economy"
example "ovbpek/economy pekovb/economy"
example "iktpek/economy"
example "iktpek/economy pekikt/economy"
example "kjapek/economy"
example "kjapek/economy pekkja/economy"
end

rule 10 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "8%"
comment "Повышенные комиссии из Алматы в Китай"
agent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent_comment "5% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subclasses "CDIZ"
routes "ALA-CN/OW,RT"
example "alapek/d"
example "alapek/i pekala/z"
end

rule 11 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "8%"
comment "Повышенные комиссии из Алматы в Китай"
agent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent_comment "5% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
classes :economy
routes "ALA-CN/OW,RT"
example "alapek/economy"
example "alapek/economy pekala/economy"
end

rule 12 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10%"
agent_comment "9% от всех опубл. тарифов на собств. рейсы HU (880) по Китаю (только внутренний перелет, кроме из Пекина по Китаю)"
subagent_comment "7% от всех опубл. тарифов на собств. рейсы HU (880) по Китаю (только внутренний перелет, кроме из Пекина по Китаю)"
domestic
example "xmnweh"
end

rule 13 do
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
discount "4%"
agent_comment "3% начало перелета из третьей страны в Китай на все классы"
subagent_comment "1% начало перелета из третьей страны в Китай на все классы"
check %{ includes(country_iatas, "CN") and not includes(country_iatas.first, "RU CN") }
example "cdgpek"
end

rule 14 do
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
discount "4%"
agent_comment "3% перелет/ all class of the flight CHINA - RUSSIA или CHINA - RUSSIA - CHINA"
subagent_comment "1% перелет all class of the flight CHINA - RUSSIA или CHINA - RUSSIA - CHINA"
routes "CN-RU/OW,RT"
example "peksvo"
example "peksvo svopek"
end

rule 15 do
important!
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "3%"
consolidator "2%"
agent_comment "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent_comment "0%"
routes "BJS..."
domestic
example "pekxmn xmnweh"
end

