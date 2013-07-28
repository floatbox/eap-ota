carrier "HU", start_date: "2011-12-12"

example "svopek/c"
example "svopek/c/ab peksvo/c"
agent "20% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "18% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
subclasses "C"
routes "MOW-CN/OW,RT"
discount "15%"
ticketing_method "aviacenter"
commission "20%/18%"

example "svopek/d"
example "svopek/d/ab peksvo/d"
example "svopek/i/ab peksvo/i"
agent "15% от опубл.тарифов по классу D, I на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "13% от опубл.тарифов по классу D на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
subclasses "DI"
routes "MOW-CN/OW,RT"
discount "10%"
ticketing_method "aviacenter"
commission "15%/13%"

example "svopek/z"
example "svopek/z/ab peksvo/z"
agent "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
subclasses "Z"
routes "MOW-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "svopek"
example "svopek/ab peksvo"
example "svopek/ab peksvo"
comment "копия для эконом класса"
agent "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
routes "MOW-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "ledpek/c pekled/c"
example "ledpek/c/ab pekled/c"
example "ledpek/d/ab pekled/d"
agent "15% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "13% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
subclasses "CD"
routes "LED-CN/OW,RT"
discount "10%"
ticketing_method "aviacenter"
commission "15%/13%"

example "ledpek/i/ab pekled/i"
example "ledpek/z/ab pekled/z"
agent "9% от опубликованных на I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "7% от опубликованных на I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
subclasses "IZ"
routes "LED-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "ledpek/economy/ab pekled/economy"
example "ledpek/economy/ab pekled/economy"
comment "копия для эконом-класса"
agent "9% от на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "7% на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
routes "LED-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "ovbpek/c"
example "kjapek/d"
example "iktpek/i pekikt/i/ab"
example "ovbpek/z pekovb/z/ab"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
interline :no, :yes
subclasses "CDIZ"
routes "KJA,OVB,IKT-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "ovbpek"
example "kjapek"
example "iktpek pekikt/ab"
example "ovbpek pekovb/ab"
comment "копия для эконом класса"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
interline :no, :yes
routes "KJA,OVB,IKT-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "alapek/c"
example "alapek/d"
example "alapek/i pekala/i/ab"
example "alapek/z pekala/z/ab"
agent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
interline :no, :yes
subclasses "CDIZ"
routes "ALA-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "7%/7%"

example "alapek"
example "alapek"
example "alapek pekala/ab"
example "alapek pekala/ab"
comment "копия для эконом класса"
agent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
interline :no, :yes
routes "ALA-CN/OW,RT"
discount "5.5%"
ticketing_method "aviacenter"
commission "7%/7%"

example "pekweh"
example "nayweh wehnay"
agent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
routes "BJS..."
domestic
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

example "peksvo/m"
example "peksvo/m svopek/c"
agent "3% перелет/ all class of the flight CHINA - RUSSIA или CHINA - RUSSIA - CHINA"
subagent "1% перелет all class of the flight CHINA- RUSSIA или CHINA- RUSSIA - CHINA"
classes :first, :business, :economy
routes "CN-RU/OW,RT"
ticketing_method "aviacenter"
commission "3%/1%"

example "miapek"
example "XMNPEK PEKHKT"
comment "расширили правило: + из Китая куда угодно, кроме вылетов из PEK"
agent "3% начало перелета из третьей страны в Китай на все классы"
subagent "1% начало перелета из третьей страны в Китай на все классы"
routes "...CN..."
ticketing_method "aviacenter"
check %{ not includes(city_iatas.first, 'BJS')}
commission "3%/1%"
