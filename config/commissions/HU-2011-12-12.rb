carrier "HU", start_date: "2011-12-12"

rule 1 do
example "svopek/c"
example "svopek/c/ab peksvo/c"
agent_comment "20% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "18% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
subclasses "C"
routes "MOW-CN/OW,RT"
discount "15%"
ticketing_method "aviacenter"
agent "20%"
subagent "18%"
end

rule 2 do
example "svopek/d"
example "svopek/d/ab peksvo/d"
example "svopek/i/ab peksvo/i"
agent_comment "15% от опубл.тарифов по классу D, I на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "13% от опубл.тарифов по классу D на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
subclasses "DI"
routes "MOW-CN/OW,RT"
discount "10%"
ticketing_method "aviacenter"
agent "15%"
subagent "13%"
end

rule 3 do
example "svopek/z"
example "svopek/z/ab peksvo/z"
agent_comment "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
subclasses "Z"
routes "MOW-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 4 do
example "svopek"
example "svopek/ab peksvo"
example "svopek/ab peksvo"
comment "копия для эконом класса"
agent_comment "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent_comment "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
routes "MOW-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 5 do
example "ledpek/c pekled/c"
example "ledpek/c/ab pekled/c"
example "ledpek/d/ab pekled/d"
agent_comment "15% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent_comment "13% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
subclasses "CD"
routes "LED-CN/OW,RT"
discount "10%"
ticketing_method "aviacenter"
agent "15%"
subagent "13%"
end

rule 6 do
example "ledpek/i/ab pekled/i"
example "ledpek/z/ab pekled/z"
agent_comment "9% от опубликованных на I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent_comment "7% от опубликованных на I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
subclasses "IZ"
routes "LED-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 7 do
example "ledpek/economy/ab pekled/economy"
example "ledpek/economy/ab pekled/economy"
comment "копия для эконом-класса"
agent_comment "9% от на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent_comment "7% на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
routes "LED-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 8 do
example "ovbpek/c"
example "kjapek/d"
example "iktpek/i pekikt/i/ab"
example "ovbpek/z pekovb/z/ab"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
interline :no, :yes
subclasses "CDIZ"
routes "KJA,OVB,IKT-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 9 do
example "ovbpek"
example "kjapek"
example "iktpek pekikt/ab"
example "ovbpek pekovb/ab"
comment "копия для эконом класса"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent_comment "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
interline :no, :yes
routes "KJA,OVB,IKT-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 10 do
example "alapek/c"
example "alapek/d"
example "alapek/i pekala/i/ab"
example "alapek/z pekala/z/ab"
agent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
interline :no, :yes
subclasses "CDIZ"
routes "ALA-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "7%"
subagent "7%"
end

rule 11 do
example "alapek"
example "alapek"
example "alapek pekala/ab"
example "alapek pekala/ab"
comment "копия для эконом класса"
agent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent_comment "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
interline :no, :yes
routes "ALA-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
agent "7%"
subagent "7%"
end

rule 12 do
example "pekweh"
example "nayweh wehnay"
agent_comment "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent_comment "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
routes "BJS..."
domestic
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 13 do
example "peksvo/m"
example "peksvo/m svopek/c"
agent_comment "3% перелет/ all class of the flight CHINA - RUSSIA или CHINA - RUSSIA - CHINA"
subagent_comment "1% перелет all class of the flight CHINA- RUSSIA или CHINA- RUSSIA - CHINA"
classes :first, :business, :economy
routes "CN-RU/OW,RT"
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
end

rule 14 do
example "miapek"
example "XMNPEK PEKHKT"
comment "расширили правило: + из Китая куда угодно, кроме вылетов из PEK"
agent_comment "3% начало перелета из третьей страны в Китай на все классы"
subagent_comment "1% начало перелета из третьей страны в Китай на все классы"
routes "...CN..."
ticketing_method "aviacenter"
check %{ not includes(city_iatas.first, 'BJS')}
agent "3%"
subagent "1%"
end

