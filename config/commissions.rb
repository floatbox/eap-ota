carrier "SU", "Aeroflot", start_date: "2013-06-01"
########################################

example "svocdg"
example "svocdg cdgsvo"
example "svocdg/su cdgsvo/ab"
agent "4% от тарифа на собств. рейсы SU, вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам;"
subagent "3% от тарифа на собств. рейсы SU, вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам;"
interline :no, :yes
ticketing_method "aviacenter"
discount "3%"
commission "4%/3%"

example "cdgsvo/ab"
agent "1.3. На рейсы других авиакомпаний по соглашениям «Интерлайн» при продаже перевозок без комбинации с рейсом под кодом «SU»:"
agent "- 1 евро по курсу GDS на день выписки авиабилета) за авиаперевозку  (в рублевом эквиваленте, исчисляемом по расчетному курсу, установленному ОАО «Аэрофлот» на день оформления авиабилета с округлением до целого числа в большую сторону);"
agent "- 1 евро по курсу GDS на день выписки авиабилета) при переоформлении авиабилета с доплатой по тарифу (в рублевом эквиваленте, исчисляемом по расчетному курсу, установленному ОАО «Аэрофлот» на день оформления  авиабилета с округлением до целого числа в большую сторону); "
subagent "• на рейсы Interline без комбинации с рейсом под кодом «SU»:"
subagent "5 (пять) руб. с авиабилета (в т.ч. при переоформлении авиабилета с доплатой по тарифу)."
interline :absent
ticketing_method "aviacenter"
#discount '5'
## our_markup 100
consolidator "2%"
commission "1eur/5"

example 'svosip/VV'
example 'odssvo svoods/VV'
check %{ includes(city_iatas, 'SIP ODS') }
interline :no, :yes, :absent
ticketing_method "aviacenter"
important!
no_commission "Катя просила выключить срочно от 14.06.12"

example "svocdg/p"
agent ""
subagent ""
subclasses "P"
ticketing_method "aviacenter"
important!
no_commission "закрыли субсидированные тарифы"

carrier "SU", "Aeroflot", start_date: "2013-07-01"
########################################

example "svocdg"
example "svocdg cdgsvo"
example "svocdg/su cdgsvo/ab"
agent "4%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent "3%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
check %{ includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "4%"
commission "4%/3%"

example "cdgsvo"
example " cdgsvo/ab svocdg/su"
agent "1 евро с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent "5 (пять) руб. с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
ticketing_method "aviacenter"
#discount '5'
## our_markup 100
consolidator "2%"
check %{ not includes_only(country_iatas.first, 'RU') }
commission "1eur/5"

example "cdgsvo/ab"
agent "1 евро с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, 'нетто'."
subagent "5 (пять) руб.  с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, нетто'."
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
#discount '5'
## our_markup 100
commission "1eur/5"

example 'odssvo svoods/VV'
check %{ includes(city_iatas, 'SIP ODS') }
interline :no, :yes, :absent
ticketing_method "aviacenter"
important!
no_commission "Катя просила выключить срочно от 14.06.12"

example "svocdg/p"
agent ""
subagent ""
subclasses "P"
ticketing_method "aviacenter"
important!
no_commission "закрыли субсидированные тарифы"

carrier "UN", "TRANSAERO", start_date: "21.06.2013"
########################################

#dtt
example 'AERDME/W DMEAER/W'
example 'AERDME/W DMEAER/I'
example 'AERDME/N DMEAER/T'
example 'AERDME/W DMEAER/W'
agent "5% американский office-id"
subagent "4% от тарифа на рейсы Перевозчика по всем тарифам классов L,V,X,T,N,I,W."
subclasses "LVXTNIW"
ticketing_method "downtown"
discount "3%"
commission "5%/4%"

# базовое вознаграждение ац для высоких c 21.06
example 'cdgsvo/r svocdg/f'
agent "7% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent "5%"
subclasses "FPRJCADSM"
ticketing_method "aviacenter"
discount "6%"
important!
commission "7%/5%"

# базовое вознаграждение ац c 21.06.2013 
example 'cdgsvo/h svocdg/y'
agent "C 21.06.13г. 5% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K;"
subagent "3%"
subclasses "YHQBK"
ticketing_method "aviacenter"
discount "4%"
# disabled "На DTT выгодней"
commission "5%/3%"

# говноклассы с 21.06 
example 'cdgsvo/g svocdg/u'
agent "3% от тарифа на рейсы Перевозчика по всем тарифам Туристического класса;"
subagent "1% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U;"
subclasses "GU"
ticketing_method "aviacenter"
discount "2%"
commission "3%/1%"

# интерлайн c 21.05.2013 (не меняется)
example 'aerdme dmeaer/ab'
agent "5% Interline с участком Трансаэро. Без участка UN запрещено."
subagent "3% от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без
участка UN"
ticketing_method "aviacenter"
interline :yes
discount "4%"
commission "5%/3%"

# дополнительно:
# Хьюстон-Сингапур
example 'svoiws/UN7061'
example 'svoaap/UN7061 aapsvo/UN7061'
example 'dmesin/UN7062 sindme/UN7062'
agent "9% до особых указаний от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса  между пунктами полетов ОАО «АК «ТРАНСАЭРО»  на территории России и Хьюстоном/Сингапуром (OW, RT)."
subagent "до особых указаний 7% от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса между пунктами полетов ОАО «АК «ТРАНСАЭРО» на территории России и Хьюстоном/Сингапуром (OW, RT)."
ticketing_method "aviacenter"
important!
check %{ includes(city_iatas, 'HOU SIN') and includes(city_iatas, 'MOW') and includes(country_iatas, 'RU') }
# disabled "На DTT выгодней"
discount "8%"
commission "9%/7%"

# Пекин прямые из Москвы и сквозные через Москву из RU UA KZ UZ AM — через dtt
example 'kbpsvo svopek'
example 'tsedme dmepek pekdme dmetse'
agent "12% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "10% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
subagent "10% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
ticketing_method "aviacenter"
check %{ includes(city_iatas, 'BJS') and includes(city_iatas, 'MOW') and includes(country_iatas, %W(RU UA KZ UZ AM)) }
discount "8.3%"
important! # ац вперед! 
no_commission "12%/10%"

# Майами/Нью-Йорк прямые из Москвы и сквозные через Москву из RU UA KZ UZ AM — через dtt
example 'kbpsvo svojfk'
example 'tsedme dmejfk jfkdme dmetse'
agent "12% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "11% до особых указаний от всех опубл. тарифов (OW/RT) на собств. ПРЯМЫЕ рейсы UN между Москвой и городами:Нью-Йорк/ Майами/ Лос-Анджелес/ Пекин;"
subagent "11% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
check %{ includes(city_iatas, %W(NYC MIA LAX)) and includes(city_iatas, 'MOW') and includes(country_iatas, %W(RU UA KZ UZ AM)) }
# FIX кривой и не полный чек
discount "9%"
important! # ац вперед! 
ticketing_method "downtown"
# disabled "dtt рулит"
commission "12%/11%"

example 'svocdg/lh cdgmad/lh'
interline :absent
no_commission

carrier "2U", "SUN D’OR International Airlines (РИНГ-АВИА)"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств. рейсы 2U (В договоре Interline отдельно не прописан.)"
subagent "3,5% от опубл. тарифов на собств. рейсы 2U"
ticketing_method "aviacenter"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
ticketing_method "aviacenter"
interline :unconfirmed
commission "5%/3.5%"

carrier "5N", "Нордавиа-РА", start_date: "01.12.2012"
########################################

example 'svocdg'
agent " 4% от всех опубликованных тарифов на рейсы 5N"
subagent "3% от всех опубликованных тарифов на рейсы 5N"
ticketing_method "aviacenter"
discount "3%"
commission "4%/3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
ticketing_method "aviacenter"
interline :yes
discount "5%"
# our_markup 120
commission "7%/5%"

carrier "6H", "ISRAIR AIRLINE", start_date: "01.07.2011"
########################################

example 'svocdg'
agent    "С 01.07.11г. 5% от всех опубл. тарифов на рейсы 6H (В договоре Interline отдельно не прописан.)"
subagent "С 01.07.11г. 3% от опубл. тарифов на собств.рейсы 6H"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
ticketing_method "aviacenter"
interline :unconfirmed
consolidator "2%"
commission "1/0"

carrier "7B", "ATLANT-SOYUZ"
########################################

disabled "Suspension of Moscow Airlines (7B/499)"
example 'svocdg'
agent    "4% от всех опубл. тарифов на cобств. рейсы 7B"
subagent "2,8% от опубл. тарифов на cобств. рейсы 7B"
ticketing_method "aviacenter"
commission "4%/2.8%"


disabled "Suspension of Moscow Airlines (7B/499)"
example 'cdgsvo svocdg/ab'
agent    "3% от всех опубл. тарифов на рейсы Interline"
subagent "2% от опубл. тарифов на рейсы Interline"
ticketing_method "aviacenter"
interline :yes
commission "3%/2%"

example 'svocdg/ab'
no_commission

carrier "7D", "DONBASSAERO", start_date: "11.04.2011"
########################################

#example 'svocdg'
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на собств. рейсы 7D;"
ticketing_method "aviacenter"
discount "2%"
disabled "out of BSP"
commission "5%/3.5%"

#example 'cdgsvo svocdg/ab'
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на интерлайн-перевозки как с участием собственных, так и без участия собственных рейсов (только рейсы интерлайн-партнёров) авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на рейсы Interline с уч. собств. рейсов 7D;"
ticketing_method "aviacenter"
interline :yes, :absent
discount "2%"
disabled "out of BSP"
commission "5%/3.5%"

carrier "7W", "WINDROSE"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на собств.рейсы 7W"
subagent "6,3% от опубл. тарифов на собств.рейсы 7W"
ticketing_method "aviacenter"
discount "6.3%"
commission "9%/6.3%"

example 'svocdg cdgsvo/ab'
agent    "5% от всех опубл. тарифов на рейсы Interline c участком 7W"
subagent "3,5% от опубл. тарифов на рейсы Interline c участком 7W"
ticketing_method "aviacenter"
interline :yes
discount "2%"
commission "5%/3.5%"

carrier "9W", "JET AIRWAYS (Авиарепс)"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от опубл. тарифов на собств.рейсы 9W"
agent    "1% от опубл. тарифов на рейсы Interline с участком 9W (Выписка без участка 9W запрещена.)"
subagent "0,5% от опубл. тарифа на собств.рейсы 9W"
ticketing_method "aviacenter"
interline :no, :yes
commission "1%/0.5%"

example 'cdgsvo/ab'
no_commission

carrier "AA", "AMERICAN AIRLINES"
########################################

example 'svocdg'
agent    "1% от опубл. тарифа на собственные рейсы AA, кроме:"
subagent "0,5% от опубл. тарифа на собственные рейсы AA, кроме:"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'miaiad'
agent    "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
subagent "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
ticketing_method "aviacenter"
important!
check %{ includes(%W(US CA PR VI), country_iatas.first) }
our_markup "0.5%"
consolidator "2%"
commission "0%/0%"

example 'miaiad iadmia/ab'
agent "Решили с Любой включить интерлайн, хотя он и не прописан"
subagent "Решили с Любой включить интерлайн, хотя он и не прописан"
ticketing_method "aviacenter"
interline :unconfirmed
our_markup "0.5%"
consolidator "2%"
commission "0%/0%"

agent    "0% от тарифов VUSA, N1VISIT и N2VISIT."
subagent "0% от тарифов VUSA, N1VISIT и N2VISIT."
ticketing_method "aviacenter"
disabled "ни разу не попадались"
consolidator "2%"
commission "0%/0%"

carrier "AB", "AIR BERLIN", start_date: "2013-06-05"
########################################

example 'cdgfra/m fracdg/s'
agent    "8% по всем направлениям через DTT"
subagent "6% по всем направлениям через DTT"
interline :no
# только собственные рейсы AB и HG
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
discount "5.5%"
ticketing_method "downtown"
commission "8%/6%"

example 'cdgfra/S7:AB'
example 'cdgsvo svocdg/lh'
agent    "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent "5 коп с билета по опубл. тарифам на рейсы AB"
interline :no, :unconfirmed
our_markup "1%"
ticketing_method "direct"
consolidator "2%"
commission "1/0.05"

example 'svocdg/s7'
no_commission

carrier "AB", "AIR BERLIN", start_date: "2013-07-01"
########################################

example 'cdgfra/m fracdg/s'
agent    "8% по всем направлениям через DTT"
subagent "6% по всем направлениям через DTT"
interline :no
# только собственные рейсы AB и HG
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
discount "5.5%"
ticketing_method "downtown"
commission "8%/6%"

# example 'cdgfra/m fracdg/s'
agent "5% (3%) (3%) за все опубл. тарифы, включая групповые (комиссия не распространяется на:топливный сбор, сбор за безопасность и все остальные сборы, а также на дополнительные услуги)."
agent "Период бронирования и выписки: С 5 по 31.07.2013г (включительно)."
agent "Период путешествия: Любые даты, начиная с 5 июня 2013 г."
agent "Применяется только к рейсам, выполняемым airberlin group (AB/HG/4T). Билеты должны быть выписаны на бланках AB/745."
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
ticketing_method "aviacenter"
consolidator "2%"
discount "3%"
disabled "пока dtt?"
commission "5%/3%"

example 'cdgfra/S7:AB'
example 'cdgsvo svocdg/lh'
agent    "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent "5 коп с билета по опубл. тарифам на рейсы AB"
interline :no, :unconfirmed
our_markup "1%"
ticketing_method "direct"
consolidator "2%"
commission "1/0.05"

example 'svocdg/s7'
no_commission

carrier "AC", "AIR CANADA (НЕ BSP!!!)"
########################################

# example 'svojfk/f'
# example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
discount "6%"
disabled "на свои не продается"
commission "10%/8%"

# example 'svojfk/q'
# example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
discount "4%"
disabled "на свои не продаем"
commission "8%/6%"

# example 'svojfk/y'
# example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
discount "1.5%"
disabled "на свои не продаем"
commission "5%/3%"

carrier "AF", "AIR FRANCE", start_date: "15.05.2013"
########################################

example 'jfksvo/c svojfk/n'
example 'jfksvo/v'
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I W,S,Y,M,U,K,H A,L,Q,T,N,R,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIWSYMUKHALQTNRV"
check %{ includes(country_iatas, 'RU') and includes(country_iatas.first, 'US') and includes_only(country_iatas, 'US RU') }
ticketing_method "downtown"
discount "5%"
commission "8%/6%"

#start_date "01.07.2012"
example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ;"
agent    "1 руб. за билет,выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ, 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
ticketing_method "aviacenter"
interline :no, :yes
# discount "1.5%"
consolidator "2%"
commission "1/0.05"

example 'cdgsvo/ab'
no_commission

carrier "AM", "AEROMEXICO"
########################################

example "SVOCDG"
agent    "9% от всех опубликованных тарифов"
subagent "7% от опубл. тарифов на рейсы AM"
ticketing_method "aviacenter"
interline :no, :yes
discount "7%"
commission "9%/7%"

carrier "AY", "FINNAIR"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета на рейсы AY (Билеты «Интерлайн» под кодом АY могут быть выписаны только в случае использования опубл. тарифов или тарифов ИАТА и только при условии, если АY выполняет хотя бы один рейс при наличии действующих «Интерлайн» соглашений с другими а/к, задействованными в перевозке.)"
subagent "50 коп. с билета на рейсы AY"
ticketing_method "aviacenter"
interline :no, :yes
our_markup "0.1%"
consolidator "2%"
commission "1/0.5"

example 'cdgsvo/ab'
no_commission

carrier "AZ", "ALITALIA", start_date: "2013-06-01"
########################################

example 'svojfk/v jfksvo/m'
example 'jfksvo/o'
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то J,E,D,I P,Y,B,M,H,K A,V,T,N,S,L,O"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "JEDIPYBMHKAVTNSLO"
check %{ includes(country_iatas, 'RU') and includes(country_iatas, 'US') and includes_only(country_iatas, 'US RU') }
ticketing_method "downtown"
discount "5%"
commission "8%/6%"

example 'svolin/business'
example 'ledlin/business linled/business'
example 'ievfco/business'
example 'ievlin/business'
example 'tbsfco/business fcotbs/business'
example 'evnfco/business fcoevn/business'
agent "5% на БИЗНЕС класс."
subagent "3% от тарифа на все направления Alitalia (Эконом и Бизнес класса) с началом путешествия из Москвы и Санкт-Петербурга, а также из Киева (из Киева Alitalia летает в Рим (AZ481) и Милан (AZ7469), Тбилиси (из Тбилиси Alitalia летает в Рим (AZ551), Еревана (из Еревана Alitalia летает в Рим (AZ557) (тарифы туда и обратно, а также тарифы в одну сторону, но с вылетом из Москвы или Санкт-Петербурга, Киева, Тбилиси или Еревана). Повышенная комиссия не применяется, если начало путешествия не из этих городов. На рейсы code-share комиссия не применяется (за исключением code-share с AP/VE/XM/CT)"
classes :business
check %{
  includes_only(operating_carrier_iatas, 'AZ VE XM CT') and
  ( includes(city_iatas.first, 'MOW LED SVX') or
    (includes(city_iatas.first, 'IEV') and includes_only(city_iatas, 'IEV ROM MIL')) or
    (includes(city_iatas.first, 'TBS') and includes_only(city_iatas, 'TBS ROM')) or
    (includes(city_iatas.first, 'EVN') and includes_only(city_iatas, 'EVN ROM'))
  )
}
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

example 'svolin/az565 linsvo/AZ560'
example 'svolin/az565 linsvo/AZ560 svocdg'
example 'svolin/az565 linsvo/AZ564'
agent "4% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
agent "с обязательным наличием в маршруте рейса Москва-Милан AZ565 или AZ56 и обязательным наличием в маршруте рейса Милан-Москва AZ560 и AZ564."
subagent "2% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
classes :economy
check %{ includes(flights.every.full_flight_number, %W(AZ565 AZ56)) and includes(flights.every.full_flight_number, %W(AZ560 AZ564)) }
ticketing_method "aviacenter"
discount "2%"
commission "4%/2%"

example 'mrucdg'
example 'mrucdg cdgmru'
agent    "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
ticketing_method "aviacenter"
our_markup "0.2%"
commission "1eur/5"

example 'svocdg cdgsvo/ab'
agent    "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
ticketing_method "aviacenter"
our_markup "0.2%"
commission "1eur/5"

example 'svocdg/ab cdgsvo'
no_commission

carrier "AZ", "ALITALIA", start_date: "2013-07-01"
########################################

# example 'svojfk/v jfksvo/m'
# example 'jfksvo/o'
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то J,E,D,I P,Y,B,M,H,K A,V,T,N,S,L,O"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "JEDIPYBMHKAVTNSLO"
check %{ includes(country_iatas, 'RU') and includes(country_iatas, 'US') and includes_only(country_iatas, 'US RU') }
ticketing_method "downtown"
discount "5%"
disabled "отмена повышенной! мега срочно"
commission "8%/6%"

# example 'svolin/az565 linsvo/AZ560'
# example 'svolin/az565 linsvo/AZ560 svocdg'
# example 'svolin/az565 linsvo/AZ564'
agent "4% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
agent "с обязательным наличием в маршруте рейса Москва-Милан AZ565 или AZ56 и обязательным наличием в маршруте рейса Милан-Москва AZ560 и AZ564."
subagent "2% от тарифа ЭКОНОМ КЛАССА на ВСЕ НАПРАВЛЕНИЯ ALITALIA с вылетом из Москвы"
classes :economy
check %{ includes(flights.every.full_flight_number, %W(AZ565 AZ56)) and includes(flights.every.full_flight_number, %W(AZ560 AZ564)) }
ticketing_method "aviacenter"
discount "1%"
disabled "отмена повышенной! мега срочно"
commission "4%/2%"

example 'mrucdg'
example 'mrucdg cdgmru'
agent    "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
ticketing_method "aviacenter"
our_markup "0.2%"
commission "1eur/5"

example 'svocdg cdgsvo/ab'
agent    "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
ticketing_method "aviacenter"
our_markup "0.2%"
commission "1eur/5"

example 'svocdg/ab cdgsvo'
no_commission

carrier "B2", "Belavia", start_date: "2013-05-01"
########################################

example 'svocdg'
agent    "5% от всех опубл. тарифов на собств. рейсы B2;"
subagent "3,5% от всех опубл. тарифов на собств. рейсы B2;"
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

carrier "B2", "Belavia", start_date: "2013-08-01"
########################################

example 'svocdg'
agent    "4% от всех опубл. тарифов на собств. рейсы B2;"
subagent "2,5% от всех опубл. тарифов на собств. рейсы B2;"
ticketing_method "aviacenter"
discount "2.5%"
commission "4%/2.5%"

carrier "BA", "BRITISH AIRWAYS (См. в конце таблицы продолжение в 4-х частях)", start_date: "01.01.2013"
########################################

example 'svocdg'
agent    "C 01.01.2013г. 1 рубль с билета по опубл. тарифам на собств. рейсы BA;"
subagent "5 коп. с билета"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

example 'svocdg cdgsvo/ab'
agent    "1 рубль с билета по опубл. тарифам на рейсы Interline, с участком BA. (British Airways и другие перевозчики (oneworld и авиакомпании имеющие договор interline с British Airways), выписанные на одном бланке. Правило первого перевозчика не является обязательным, то есть первый перелет может быть выполнен другой авиакомпанией. Не  разрешается использование бланков ВА для выписки других перевозчиков 
(даже авиакомпаний членов альянса oneworld) без участия ВА. Нарушение этого правила повлечет за собой ADM на сумму GBP 100."
subagent "5 коп. с билета"
ticketing_method "aviacenter"
interline :yes
consolidator "2%"
commission "1/0.05"

example 'svocdg/aa cdgsvo/aa'
example 'svocdg/ib cdgsvo/ib'
example 'svocdg/qf cdgsvo/qf'
example 'svocdg/ec cdgsvo/ec'
agent "0 руб - рейсы авиакомпаний American Airlines, Iberia, OpenSkies и Qantas, выписанные на бланке без перелетного сегмента British Airways."
subagent "0, больше агентской быть не может же"
interline :absent
check %{ includes_only(marketing_carrier_iatas, %W(AA IB EC QF)) }
ticketing_method "aviacenter"
consolidator "2%"
commission "0/0"

carrier "BD", "BMI"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета по опубл.тарифам"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы BD и рейсы Interline с участком BD"
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0.2%"
disabled "вышли из bsp"
commission "1/0.05"

example 'svocdg/ab'
no_commission

carrier "BI", "ROYAL BRUNEY AIRLINES"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы BI (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы BI"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "BT", "AIR BALTIC"
########################################

example 'svocdg cdgsvo'
example 'svocdg cdgsvo/ab'
agent "1 руб. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT"
subagent "50 КОП. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT +2% сбор АЦ"
interline :no, :yes
ticketing_method "aviacenter"
# discount "2.5%"
consolidator "2%"
commission "1/0.5"

carrier "CA", "AIR CHINA"
########################################

example 'ledpek'
example 'svopek peksvo'
agent "9% Все международные перелеты рейсами СА из России"
subagent "7.5% Все международные перелеты рейсами СА из России"
important!
check %{ includes(country_iatas.first, 'RU') }
interline :no
ticketing_method "aviacenter"
discount "7.5%"
commission "9%/7.5%"

example 'ledpek/ab pekhta'
example 'okopek/ab pekoko'
example 'pekycu ycupek'
example 'peksgn'
agent   "3%  от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
subagent "2.5% от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
interline :no, :yes
ticketing_method "aviacenter"
discount "2.5%"
commission "3%/2.5%"

example 'okopek/ab'
agent "  0% интерлайн без участия авиакомпании  CA ."
subagent "  0% интерлайн без участия авиакомпании  CA ."
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "CI", "China Airlines"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы CI (В договоре Interline отдельно не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы CI"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/0"

carrier "CX", "CATHAY PACIFIC (Тальавиэйшн)"
########################################

example 'svocdg'
agent    "7% от всех опубликованных и специальных тарифов"
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "7% от всех опубликованных и специальных тарифов"
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским   тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
interline :no, :yes
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

carrier "CY", "CYPRUS AIRWAYS"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на рейсы CY. (В договоре Interline не прописан.)"
subagent "7% от опубликованных тарифов на рейсы CY."
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

example 'cdgsvo svocdg/ab'
agent "??? 1р Interline не прописан"
subagent "??? 0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
discount "5.7%"
commission "9%/7%"

carrier "CZ", "CHINA SOUTHERN"
########################################

example 'svocdg'
agent    "9% от тарифа на рейсы, полностью выполняемые CZ;"
subagent "7% от тарифа на рейсы, полностью выполняемые CZ;"
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

example 'cdgsvo svocdg/ab'
agent    "7% от тарифа на рейсы CZ с участием других перевозчиков;"
subagent "5% от тарифа на рейсы CZ с участием других перевозчиков;"
interline :yes
ticketing_method "aviacenter"
discount "4.1%"
commission "7%/5%"

example 'cdgsvo/ab'
agent    "0% от тарифа на рейсы Interline без участка СZ."
subagent "0% от тарифа на рейсы Interline без участка СZ."
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "D9", "ДОНАВИА"
########################################

example 'svocdg/economy'
agent    "7% от опубл. тарифов эконом класса на собств. рейсы D9"
subagent "5% от опубл. тарифов эконом класса на собств. рейсы D9"
classes :economy
ticketing_method "aviacenter"
discount "4.5%"
commission "7%/5%"

example 'svocdg/business'
agent    "9% от опубл. тарифов бизнес класса на собств. рейсы D9"
subagent "6,3% от опубл. тарифов бизнес класса на собств. рейсы D9"
classes :business
ticketing_method "aviacenter"
discount "5.5%"
commission "9%/6.3%"

example 'svocdg cdgsvo/ab'
example 'svocdg/business cdgsvo/ab'
agent    "2% от опубл. тарифов на рейсы Interline с участком D9"
subagent "1,4% от опубл. тарифов на рейсы Interline с участком D9"
interline :yes
ticketing_method "aviacenter"
discount "1%"
commission "2%/1.4%"

carrier "DE", "Condor Flugdienst (Авиарепс)", start_date: "01.10.2011"
########################################

example 'svocdg'
agent    "1руб от всех опубл. тарифов на рейсы DE. (В договоре Interline не прописан.)"
subagent "5 коп от опубл. тарифа на рейсы DE."
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/0.05"

carrier "DL", "DELTA AIRLINES", start_date: "2013-05-15"
########################################

example 'svoadz/j adzsvo/c'
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до South America Tour Code RULAPREM); "
subagent "3%"
subclasses "JCDZI"
check %{ includes(city_iatas.first, 'MOW') and includes_only(country_iatas, 'RU AR BO BR VE GY CO PY PE SR UY FK GF CL EC') } # FIXME добавить сендвичевы острова и южную георгию
ticketing_method "downtown"
tour_code "RULAPREM"
discount "3%"
commission "5%/3%"

example 'svotab/j tabsvo/z'
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Caribbean Central Tour Code RUCBPREM); "
subagent "3%"
subclasses "JCDZI"
check %{ includes(city_iatas.first, "MOW") and includes_only(country_iatas, 'RU GY BB JM TT') }
ticketing_method "downtown"
tour_code "RUMCBREM"
discount "3%"
commission "5%/3%"

example 'svotam/j tamsvo/z'
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до Mexico Tour Code RUMXPREM ); "
subagent "3%"
subclasses "JCDZI"
check %{ includes(city_iatas.first, "MOW") and includes_only(country_iatas, 'RU MX') }
ticketing_method "downtown"
tour_code "RUMXPREM"
discount "3%"
commission "5%/3%"

#example 'svojfk/d jfksvo/i'
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до NYC Tour Code RUNYPREM);"
subagent "3%"
subclasses "JCDZI"
check %{ includes(city_iatas.first, "MOW") and includes_only(city_iatas, 'MOW NYC') }
ticketing_method "downtown"
tour_code "RUNYPREM"
discount "3%"
disabled "DL/AFKL/AZ Comission programm"
commission "5%/3%"

example 'svoyyz/c yyzsvo/i'
agent "5% (3%) (3%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ (до USA/CANADA Tour Code RUUSPREM);"
subagent "3%"
subclasses "JCDZI"
check %{ includes(city_iatas.first, "MOW") and includes_only(country_iatas, 'RU US CA') }
ticketing_method "downtown"
tour_code "RUUSPREM"
discount "3%"
commission "5%/3%"

example 'svojfk/d jfksvo/m'
example 'jfksvo/x'
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIYBMSHQWKLUTXV"
check %{ includes(country_iatas, 'RU') and includes(country_iatas, 'US') and includes_only(country_iatas, 'US RU') }
ticketing_method "downtown"
discount "5%"
important!
commission "8%/6%"

example 'accjfk/s'
example 'zigjfk/i jfkzig/s'
example 'accjfk/k jfkacc/k'
agent "5%"
subagent "3%"
subclasses "SIQKLUT"
check %{ includes_only(country_iatas.first, 'SN GH') and includes_only(country_iatas, 'US SN GH') }
ticketing_method "downtown"
discount "2.3%"
commission "5%/3%"

example 'accjfk/su:dl'
example 'zigjfk/su:dl jfkzig/su:dl'
example 'accjfk/su:dl jfkacc/su:dl'
example 'jfksvo/x/su:dl' 
agent "1%"
subagent "0.5%"
check %{ codeshare? }
important!
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'accjfk/d/az:dl'
example 'zigjfk/i/az:dl jfkzig/s/az:dl'
example 'accjfk/l/az:dl jfkacc/n/az:dl'
agent "5%"
subagent "3%"
subclasses "DIKVTNSL"
check %{ includes_only(country_iatas.first, 'SN GH') and includes_only(country_iatas, 'US SN GH') and includes_only(operating_carrier_iatas, 'AZ') }
ticketing_method "downtown"
important!
discount "2.3%"
commission "5%/3%"

# example 'okocdg cdgoko/ab'
# example 'cdgoko'
# example 'okomia'
#example 'jfkbwi' временно выключен
agent    "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
check %{ includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
disabled "включил dtt"
ticketing_method "aviacenter"
## discount "0.3%"
commission "1%/0.5%"

example 'miadtw dtwmia'
example 'miadtw dtwmia/ab'
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
domestic
important!
ticketing_method "aviacenter"
## discount "0.3%"
commission "1%/0.5%"

example 'cdgsvo/ab'
agent    "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
ticketing_method "aviacenter"
## discount "0.3"
commission "1%/0.5%"

example 'EWRDTW DTWYYZ' # ньюйорк - детройт - торонто
agent    "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :no, :yes
check %{ includes(%W(PR US VI CA), country_iatas.first) }
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "DL", "DELTA AIRLINES", start_date: "2014-04-01"
########################################

example 'svojfk/d jfksvo/m'
example 'jfksvo/x'
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I Y,B,M,S,H,Q W,K,L,U,T,X,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIYBMSHQWKLUTXV"
check %{ includes(country_iatas, 'RU') and includes(country_iatas, 'US') and includes_only(country_iatas, 'US RU') }
ticketing_method "downtown"
discount "5%"
commission "8%/6%"

# example 'svojfk/f'
# example 'svojfk/c jfksvo/d'
agent "4% (2%) (2%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ;"
subagent "4% (2%) (2%) от опубл. тарифа Бизнес класса (J,C,D,Z,I) на собств.рейсы DL с вылетами из МОСКВЫ;"
subclasses "JCDZI"
check %{ includes(city_iatas.first, 'MOW') }
ticketing_method "aviacenter"
discount "2%"
disabled "продаем по dtt"
commission "4%/2%"

# example 'okocdg cdgoko/ab'
# example 'cdgoko'
# example 'okomia'
#example 'jfkbwi' временно выключен
agent    "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
check %{ includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
disabled "включил dtt"
ticketing_method "aviacenter"
## discount "0.3%"
commission "1%/0.5%"

example 'miadtw dtwmia'
example 'miadtw dtwmia/ab'
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
domestic
important!
ticketing_method "aviacenter"
## discount "0.3%"
commission "1%/0.5%"

example 'cdgsvo/ab'
agent    "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
ticketing_method "aviacenter"
## discount "0.3"
commission "1%/0.5%"

example 'EWRDTW DTWYYZ' # ньюйорк - детройт - торонто
agent    "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :no, :yes
check %{ includes(%W(PR US VI CA), country_iatas.first) }
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "EK", "EMIRATES"
########################################

example 'svocdg/first cdgsvo/business'
example 'svocdg/first cdgsvo/first'
agent    "5% от тарифов Первого и Бизнес классов на рейсы EK;"
subagent "3,5% от тарифов Первого и Бизнес классов на рейсы EK;"
classes :first, :business
check %{ includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

example 'svocdg/business cdgsvo'
example 'svocdg/first cdgsvo'
agent    "5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
subagent "3,5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
check %{ includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

example 'svocdg'
agent    "1 руб. с билета по опубл.тарифам Эконом класса на рейсы EK."
subagent "5 коп. с билета по опубл.тарифам Эконом класса на собств. рейсы EK."
classes :economy
check %{ includes_only(country_iatas.first, 'RU') }
important!
ticketing_method "aviacenter"
our_markup '0'
commission "1/0.05"

example 'jfkcdg'
agent "1 руб. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
subagent "С 01.01.13г. 5 коп. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
check %{ not includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
commission "1/0.05"

example 'svocdg/business cdgsvo/ab/business svoled/business ledsvo/business'
agent    "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "3.5%"
classes :first, :business
interline :less_than_half
check %{ includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

# интерлайновые копии
# example 'svocdg/first cdgsvo/ab/business svoled ledsvo'
agent    "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "3.5%"
interline :less_than_half
check %{ includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "2%"
disabled "Пока не разруливается с чистым экономом на уровне спеки: также как и с OW example в чистом правиле не сделать"
commission "5%/3.5%"

example 'svocdg cdgsvo/ab svoled ledsvo'
agent    "1 рубль (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "5 коп"
classes :economy
interline :less_than_half
check %{ includes_only(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
our_markup '20'
commission "1/0.05"

example 'svocdg cdgled/ab ledsvo/ab'
example 'svocdg/ab cdgsvo/ab'
no_commission

carrier "ET", "Ethiopian Airlines Enterprise  (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы ET"
subagent "5% от опубл. тарифов на собств. рейсы ET"
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "5 % от опубл. тарифов на рейсы Interline с участком ET"
subagent "3,5 % от опубл. тарифов на рейсы Interline с участком ET"
interline :yes
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

example 'cdgsvo/ab'
agent    "0 % от опубл. тарифов на рейсы Interline без участка ET"
subagent "0 % от опубл. тарифов на рейсы Interline без участка ET"
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "EY", "ETIHAD AIRWAYS"
########################################

example 'svocdg'
agent   "5% от опубл. тарифов на собств. рейсы EY (В договоре Interline не прописан.)"
subagent "3.5% от опубл. тарифов на собств. рейсы EY (В договоре Interline не прописан.)"
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0"

carrier "F7", "FLY BABOO (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств.рейсы F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тар. на рейсы Interline c участком F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/0%"

example 'cdgsvo/ab'
agent    "1% от опубл. тар. на рейсы Interline без участка F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/0%"

carrier "FB", "BULGARIA AIR"
########################################

example 'svocdg'
agent    "4% от опубл. тарифов на собств. рейсы FB. (В договоре Interline не прописан.)"
subagent "2,8% от опубл. тарифов на собств. рейсы FB."
ticketing_method "aviacenter"
discount "2%"
commission "4%/2.8%"

example 'cdgsvo svocdg/ab'
agent "??? 1р Interline не прописан"
subagent "??? 0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
discount "2%"
commission "4%/2.8%"

carrier "FI", "ICELANDAIR  (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы FI (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы FI"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1% от опубл. тарифов на рейсы Interline с обязательным участием FI."
subagent "0,5% от опубл. тарифов на рейсы Interline с обязательным участием FI."
interline :yes
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "FV", "RUSSIA", start_date: "2013-06-21"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent "4% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
subagent "2% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
ticketing_method "aviacenter"
discount "2%"
commission '4%/2%'

example 'svocdg/ab'
agent "1 euro с билета на рейсы Interline без участка FV."
subagent "5 руб. с билета на рейсы Interline без участка FV."
interline :absent
ticketing_method "aviacenter"
## discount '1'
consolidator "2%"
commission "1eur/5"

example 'ledpes'
example 'ledpes/business pesled/business'
agent "9% от тарифа на собств.рейсы FV (исключая code-share) в классах Эконом и Бизнес по маршруту Санкт-Петербург-Петрозаводск или обратно."
subagent "7% от тарифа на собств.рейсы FV (исключая code-share) в классах Эконом и Бизнес по маршруту Санкт-Петербург-Петрозаводск или обратно."
classes :economy, :business
interline :no_codeshare
check %{ includes_only(city_iatas, 'LED PES') }
important!
ticketing_method "aviacenter"
discount "7%"
commission '9%/7%'

example "svocdg/r"
agent ""
subagent ""
subclasses "R"
important!
ticketing_method "aviacenter"
no_commission "закрыли субсидированные тарифы"

carrier "FV", "RUSSIA", start_date: "2013-07-01"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent "4% (2%) (2%) от опубл. тарифов на собств. (включая code-share) рейсы FV и рейсы Interline c участком FV"
subagent "2% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
ticketing_method "aviacenter"
discount "2%"
commission '4%/2%'

example 'svocdg/ab'
example 'svocdg/ab cdgsvo/ab'
agent "1 euro  (5 руб+2% сбор АЦ) (0%) с билета на рейсы Interline без участка FV."
subagent "5 рублей"
interline :absent
ticketing_method "aviacenter"
discount "2%"
commission '1eur/5'

example "svocdg/r"
agent ""
subagent ""
subclasses "R"
important!
ticketing_method "aviacenter"
no_commission "закрыли субсидированные тарифы"

carrier "GF", "GULF AIR (Глонасс) (НЕ BSP!!!)"
#######################################

agent    "7% от тарифа на международные рейсы GF"
subagent "5% от тарифа на международные рейсы GF"
interline :no
ticketing_method "aviacenter"
disabled "не bsp"
commission "7%/5%"

agent    "5% от тарифа на рейсы GF между аэропортами Персидского залива"
subagent "3,5% от тарифа на рейсы GF между аэропортами Персидского залива"
ticketing_method "aviacenter"
disabled "не bsp"
commission "5%/3.5%"

carrier "HM", "AIR SEYCHELLES (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифа на собств. рейсы HM (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы HM"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "HR", "HAHN AIR  (Авиарепс)", start_date: "2013-06-27"
########################################

# включено с дополнительной проверкой
example 'svocdg'
example "svocdg/qr"
agent    "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent    "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent    "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent "5 коп. с билета по опубл. тарифам HR"
interline :no, :absent
ticketing_method "aviacenter"
our_markup "20"
consolidator "2%"
commission "1/0.05"

carrier "HR", "HAHN AIR (Авиарепс)", start_date: "2013-07-10"
########################################

# включено с дополнительной проверкой
example 'svocdg'
example 'svocdg/qr'
agent    "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent    "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent    "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent "5 коп. с билета по опубл. тарифам HR"
interline :no, :absent
ticketing_method "aviacenter"
our_markup "20"
consolidator "2%"
commission "1/0.05"

example 'svocdg/ab'
example 'svocdg/hg'
example 'svocdg/ab cdgsvo'
example 'svocdg/hg cdgsvo'
agent "Настоящим сообщаю вам, что Интерлайн-соглашение между airberlin и Hahn Air прекращает свое действие 9 июля 2013 г.
Рейсы AB/HG нельзя будет выписывать на бланках HR/169, начиная с 10 июля 2013 г."
subagent ""
interline :yes, :absent
check %{ includes(operating_carrier_iatas, 'AB HG') }
ticketing_method "aviacenter"
important!
no_commission

carrier "HU", "HAINAN AIRLINES", start_date: "2011-12-12"
########################################

example 'svopek/c'
example 'svopek/c/ab peksvo/c'
agent "20% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "18% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "C"
interline :no, :yes
check %{ includes(city_iatas.first, 'MOW') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "15%"
commission "20%/18%"

example 'svopek/d'
example 'svopek/d/ab peksvo/d'
example 'svopek/i/ab peksvo/i'
agent "15% от опубл.тарифов по классу D, I на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "13% от опубл.тарифов по классу D на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "DI"
interline :no, :yes
check %{ includes(city_iatas.first, 'MOW') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "10%"
commission "15%/13%"

example 'svopek/z'
example 'svopek/z/ab peksvo/z'
agent "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "Z" 
interline :no, :yes
check %{ includes(city_iatas.first, 'MOW') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

# копия для эконом класса
example 'svopek'
example 'svopek/ab peksvo'
example 'svopek/ab peksvo'
agent "9% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "7% от опубл.тарифов по классам Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
check %{ includes(city_iatas.first, 'MOW') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

example 'ledpek/c pekled/c'
example 'ledpek/c/ab pekled/c'
example 'ledpek/d/ab pekled/d'
agent "15% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "13% от опубл.тарифов по классу С,D на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
subclasses "CD"
interline :no, :yes
check %{ includes(city_iatas.first, 'LED') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "10%"
commission "15%/13%"

example 'ledpek/i/ab pekled/i'
example 'ledpek/z/ab pekled/z'
agent "9% от опубликованных на I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "7% от опубликованных на I, Z, а также на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
subclasses "IZ"
interline :no, :yes
check %{ includes(city_iatas.first, 'LED') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

# копия для эконом-класса
example 'ledpek/economy/ab pekled/economy'
example 'ledpek/economy/ab pekled/economy'
agent "9% от на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "7% на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
check %{ includes(city_iatas.first, 'LED') and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

example 'ovbpek/c'
example 'kjapek/d'
example 'iktpek/i pekikt/i/ab'
example 'ovbpek/z pekovb/z/ab'
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subclasses "CDIZ"
interline :no, :yes
check %{ includes(%W(KJA OVB IKT), city_iatas.first) and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

# копия для эконом класса
example 'ovbpek'
example 'kjapek'
example 'iktpek pekikt/ab'
example 'ovbpek pekovb/ab'
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
interline :no, :yes
check %{ includes(%W(KJA OVB IKT), city_iatas.first) and includes_only(country_iatas, 'RU CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

example 'alapek/c'
example 'alapek/d'
example 'alapek/i pekala/i/ab'
example 'alapek/z pekala/z/ab'
agent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subclasses "CDIZ"
interline :no, :yes
check %{ includes(city_iatas.first, 'ALA') and includes_only(country_iatas, 'KZ CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "7%/7%"

# копия для эконом класса
example 'alapek'
example 'alapek'
example 'alapek pekala/ab'
example 'alapek pekala/ab'
agent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
interline :no, :yes
check %{ includes(city_iatas.first, 'ALA') and includes_only(country_iatas, 'KZ CN') }
ticketing_method "aviacenter"
discount "5.8%"
commission "7%/7%"

example 'pekweh'
example 'nayweh wehnay'
agent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
check %{ includes_only(country_iatas, 'CN') and includes(city_iatas.first, 'BJS') }
ticketing_method "aviacenter"
domestic
consolidator "2%"
commission "0%/0%"

example 'peksvo/m'
example 'peksvo/m svopek/c'
agent "3% перелет/ all class of the flight CHINA - RUSSIA или CHINA - RUSSIA - CHINA"
subagent "1% перелет all class of the flight CHINA- RUSSIA или CHINA- RUSSIA - CHINA"
check %{ includes(country_iatas.first, 'CN') and includes_only(country_iatas, 'CN RU') }
classes :first, :business, :economy
ticketing_method "aviacenter"
commission "3%/1%"

# расширили правило: + из Китая куда угодно, кроме вылетов из PEK
# в общем, просто широчайшее правило
example 'miapek'
example 'XMNPEK PEKHKT'
agent "3% начало перелета из третьей страны в Китай на все классы"
subagent "1% начало перелета из третьей страны в Китай на все классы"
check %{ includes(country_iatas, 'CN') }
ticketing_method "aviacenter"
commission "3%/1%"

carrier "HU", "HAINAN AIRLINES", start_date: "2013-08-01"
########################################

example 'pekxmn xmnweh'
agent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent "0%"
important!
check %{ includes_only(city_iatas.first, 'BJS') and includes_only(country_iatas, 'CN') }
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

example 'peksvo svopek'
agent "9% (7%) от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent "7% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
ticketing_method "aviacenter"
discount "5.8%"
commission "9%/7%"

carrier "HX", "Hong Kong Airlines"
########################################

example 'svocdg'
agent    "5% от всех опубл. тарифов на собств.рейсы HX (В договоре Interline не прописан.)"
subagent "3% от опубл. тарифов на собств.рейсы HX"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

carrier "HY", "UZBEKISTAN AIRWAYS (Узбекистон Хаво Йуллари) (НЕ BSP!!!)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы HY"
subagent "5% от опубл. тарифов на собств. рейсы HY"
ticketing_method "aviacenter"
discount "5%"
disabled "не bsp"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "0% от опубл. тарифов на рейсы Interline"
subagent "0% от опубл. тарифов на рейсы Interline"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
disabled "не bsp"
commission "0%/0%"

carrier "IB", "IBERIA"
########################################

example 'svocdg cdgsvo'
agent    "1 руб. с билета на рейсы IB. (Билеты Interline под кодом IB могут быть выписаны только в случае существования опубл. тарифов и только при условии, что IB выполняет первый рейс маршрута."
subagent "50 коп. с билета на рейсы IB"
# discount "1.5%"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.5"

carrier "IG", "MERIDIANA (РИНГ-АВИА)"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств.рейсы IG (В договоре Interline не прописан.)"
subagent "3,5% от опубл. тарифов на собств.рейсы IG"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
ticketing_method "aviacenter"
discount "2.5%"
interline :unconfirmed
commission "5%/3.5%"

carrier "IY", "YEMENIA YEMEN AIRWAYS"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы IY (В договоре Interline отдельно не прописан.)"
subagent "0,5% от опубл. тарифов на собств. рейсы IY"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "JJ", "TAM Linhas Aereas S.A."
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на собств. рейсы JJ (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы JJ"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

carrier "JL", "JAPAN AIRLINES INTERNATIONAL"
########################################

example 'okosvo'
agent    "7% от опубл. тарифа;"
subagent "5% от опубл. тарифа;"
international
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svooko okosvo/ab'
agent    "7% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
agent    "Оформление авиабилетов на бланках JAL по Interline  (в случае наличия рейсов других авиакомпаний) возможно  при условии  наличия  соглашения с соответствующей авиакомпанией и хотя бы одного сегмента с международным рейсом JAL."
agent    "Комиссия 7%, в этом случае,  выплачивается только, если авиабилет оформлен по опубликованным тарифам IATA (если при расчете тарифа используются  carrier fares"
agent    "других авиакомпаниях, то комиссия с них не выплачивается)."
subagent "5% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
interline :yes
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'okoaoj'
agent    "5% от тарифов на внутренние рейсы по Японии"
subagent "3,5% от тарифов на внутренние рейсы по Японии"
domestic
ticketing_method "aviacenter"
discount "3%"
commission "5%/3.5%"

carrier "JP", "ADRIA AIRWAYS"
########################################

example 'svocdg'
agent    "1 руб. с билета на рейсы JP (В договоре Interline не прописан.)"
subagent "50 коп. с билета на рейсы JP"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.5"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.5"

carrier "JU", "JAT AIRWAYS"
########################################

example 'svocdg'
agent "С 15.02.2011г. 7% от опубл. тарифов на собств. рейсы JU"
subagent "JU  С 21.02.2011г. 5% от опубл. тарифов на собств. рейсы JU"
ticketing_method "aviacenter"
discount "6%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent "С 15.02.2011г. 0% от опубл. тарифов на рейсы Interline"
subagent "С 21.02.2011г. 0% от опубл. тарифов на рейсы Interline"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "KC", "Air Astana", start_date: "11.06.2012"
########################################

example 'tsekgf'
agent    "С 11.06.12г. 4% от опубл. тарифа на собств. рейсы КС по маршрутам внутри Республики Казахстан;"
subagent "3% от тарифа по маршрутам внутри Республики Казахстан;"
domestic
ticketing_method "aviacenter"
discount "2.5%"
commission "4%/3%"

example 'svoala alasvo'
agent    "С 11.06.12г. 1 евро с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам"
subagent "С 11.06.12г. 5 руб. с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам;"
ticketing_method "aviacenter"
consolidator "2%"
commission "1eur/5"

example 'svoala/ab alasvo'
agent    "С 11.06.12г. 1 евро с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
subagent "С 11.06.12г. 5 руб. с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1eur/5"

example 'svoala/qr alasvo/qr'
agent "С 11.06.12г. 4% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
subagent "С 11.06.12г. 3% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
interline :absent
check %{ includes_only(marketing_carrier_iatas, 'QR' ) }
ticketing_method "aviacenter"
discount "2.5%"
commission "4%/3%"

carrier "KE", "KOREAN AIR"
########################################

example 'svogmp'
agent "С 01.04.2011г. 5% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
subagent "С 01.04.2011г. 3% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
check %{ includes(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

example 'gmpsvo'
agent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
subagent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
ticketing_method "aviacenter"
check %{ not includes(country_iatas.first, 'RU') }
consolidator "2%"
commission "0%/0%"

example 'svoicn icnsvo/ab'
no_commission

carrier "KL", "KLM", start_date: "15.05.2013"
########################################

example 'jfksvo/c svojfk/n'
example 'jfksvo/v'
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I W,S,Y,M,U,K,H A,L,Q,T,N,R,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIWSYMUKHALQTNRV"
check %{ includes(country_iatas, 'RU') and includes(country_iatas.first, 'US') and includes_only(country_iatas, 'US RU') }
ticketing_method "downtown"
our_markup "0.1%"
discount "5%"
commission "8%/6%"

example 'svocdg'
agent    "1руб за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 1руб за билет, выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
ticketing_method "aviacenter"
# discount "2%"
commission "1/0.05"

carrier "KM", "AIR MALTA  (Авиарепс)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы KM"
subagent "0,5% от опубл. тарифа на рейсы KM"
ticketing_method "aviacenter"
## discount "0.2%"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на рейсы Interline"
subagent "0,5% от опубл. тарифа на рейсы Interline"
interline :yes
ticketing_method "aviacenter"
## discount "0.2%"
commission "1%/0.5%"

carrier "LA", "LAN Airlines"
########################################

example 'svocdg'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LA"
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

example 'svocdg/ab cdgsvo'
agent    "1 руб. с билета по опубл. тарифам на рейсы Interline c участком LA. Interline под кодом LA может быть выписан только при условии, что LA выполняет как минимум один рейс. За несоблюдение данного условия будет начислен штраф в размере EUR200."
agent    "Оформление отдельного авиабилета на рейсы других перевозчиков в пределах региона Южная и Центральная Америка на электронном стоке  LA ВОЗМОЖНО при условии, что внешний участок, т.е. межконтинентальный перелет, осуществляется авиакомпанией LAN. При выписке разными бланками внешнего и внутренних перелетов, все сегменты должны фигурировать в одном бронировании."
agent    "Также необходимо проверять наличие MITA и BITA соглашений. В других случаях оформление авиабилетов по интерлайн соглашению на электронном стоке авиакомпании LAN Airlines (045) не разрешено."
agent    "Комиссия при оформлении авиабилетов по Interline на электронном стоке авиакомпании LAN Airlines (045) во всех случаях составляет 1 руб. Авиакомпания вправе начислить штраф (ADM) за нарушение правил оформленная билета, неверную калькуляцию и т.п."
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
interline :no, :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

carrier "LH", "LUFTHANSA"
########################################

example 'svojfk/f'
example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
discount "6%"
commission "10%/8%"

example 'svojfk/q'
example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
discount "4.5%"
commission "8%/6%"

example 'svojfk/y'
example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
discount "2.25%"
commission "5%/3%"

example 'dmebcn'
example 'bcndme dmebcn/OS'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
check %{ includes(country_iatas, 'ES FR IT CZ PT NL CH') } 
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0"
discount "0.5%"
commission "1/0.05"

example 'svooko'
example 'svooko okosvo/ab'
example 'dmejfk jfkdme/US'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0"
discount "0.5%"
commission "1/0.05"

example 'svocdg/LX'
example 'svocdg/EW'
example 'svocdg/CL'
example 'svocdg/IQ'
example 'svocdg/C3'
agent    "1 руб. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
subagent "5 коп. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
interline :absent
check %{ includes_only(marketing_carrier_iatas, %W[LX EW CL IQ C3]) }
ticketing_method "aviacenter"
our_markup "0%"
discount "0.5%"
commission "1/0.05"

example 'svocdg/ab'
no_commission

carrier "LO", "LOT", start_date: "2013-04-01"
########################################

example 'ledprg prgwaw'
example 'dmecdg cdgwaw'
agent "Даты вылета: без ограничений
5% от опубл.тарифов на собств. рейсы LO по направлениям с вылетом из России на все классы бронирования, кроме промо и групповых: L, O, U, G за исключением прямых перелетов из Москвы и Санкт Петербурга в Варшаву."
subagent "3% от опубл.тарифов на собств. рейсы LO по направлениям с вылетом из России на все классы бронирования, кроме промо и групповых: L, O, U, G за исключением прямых перелетов из Москвы и Санкт Петербурга в Варшаву."
check %{ includes(country_iatas.first, "RU") and not includes(booking_classes, "L O U G") and 
  (
    not includes_only(city_iatas, "MOW WAW") or
    not includes_only(city_iatas, "LED WAW")
  )
}
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

example 'prgled ledcdg'
agent "1 euro с билета по опубл. тарифам на все остальные рейсы LO."
subagent "5 рублей"
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0.1%"
commission "1eur/5"

carrier "LO", "LOT", start_date: "2013-07-01"
########################################

example 'ledprg prgwaw'
example 'dmecdg cdgwaw'
agent "1 евро (5 руб) (0%) на все опубл. тарифы (включая корпоративные, туроператорские, веб-тарифы и т.д. )."
subagent "5 руб"
ticketing_method "aviacenter"
consolidator "2%"
discount "0%"
commission "1eur/5"

carrier "LX", "SWISS"
########################################

example 'svojfk/f'
example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
discount "6%"
commission "10%/8%"

example 'svojfk/q'
example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
discount "4%"
commission "8%/6%"

example 'svojfk/y'
example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
discount "1.5%"
commission "5%/3%"

example 'dmebcn'
example 'bcndme dmebcn/lh'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX.
(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
check %{ includes(country_iatas, 'ES FR IT CZ PT NL CH') } 
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0"
# discount "1.5%"
commission "1/0.05"

example 'svooko okosvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX.
(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
interline :no, :yes
ticketing_method "aviacenter"
# discount "1.5%"
commission "1/0.05"

carrier "LY", "EL AL ISRAEL AIRLINES"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов Эконом класса на рейсы LY"
subagent "3,5% от опубл. тарифов Эконом класса на рейсы LY"
classes :economy
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

example 'svocdg/j cdgsvo/j'
agent    "5% от опубл. тарифов Бизнес класса J на рейсы LY"
subagent "3,5% от опубл. тарифов Бизнес класса J на рейсы LY"
subclasses "J"
important!
ticketing_method "aviacenter"
discount "3.5%"
commission "5%/3.5%"

example 'svocdg/business cdgsvo/business'
agent    "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
classes :business
ticketing_method "aviacenter"
discount "6.7%"
commission "9.7%/6.7%"

example 'svocdg cdgsvo/business'
example 'svocdg cdgsvo/ab'
no_commission

carrier "MA", "MALEV"
########################################

example "svobud/c budsvo/c"
agent "12% от тарифа по классам J,C,D,I,Y,B;"
subagent ""
subclasses "JCDIYB"
ticketing_method "aviacenter"
disabled "no subagent"
our_markup "1%"
commission "12%/0%"

example "svobud/k budsvo/k"
agent "6% от тарифа по классам K,M,L,V,S,Z, N."
subagent ""
subclasses "KMLVSZN"
disabled "no subagent"
ticketing_method "aviacenter"
our_markup "1%"
commission "6%/0%"

example "svobud budsvo/ab"
agent    "1 руб. с билета от опубл., конфиде.тарифов Эконом и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
subagent "5 коп. с билета от опубл., конфиде.тарифов Экономического и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
interline :half
disabled "ибо обанкротились (Люба сказала)"
ticketing_method "aviacenter"
our_markup "1%"
commission "1/0.05"

carrier "MK", "AIR MAURITIUS"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на рейсы MK (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы MK"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "MS", "EGYPT AIR"
########################################

example 'svocai caisvo'
agent    "9% от тарифа на рейсы MS из Москвы"
subagent "7% от тарифа на рейсы MS из Москвы"
check %{ includes(city_iatas.first, 'MOW') }
ticketing_method "aviacenter"
discount "7%"
commission "9%/7%"

example 'caisvo svocai'
agent    "5% от тарифа на рейсы MS из Египта"
subagent "3,5% от тарифа на рейсы MS из Египта"
international
check %{ includes(country_iatas.first, 'EG') }
ticketing_method "aviacenter"
discount "3%"
commission "5%/3.5%"

example 'cdgcai'
example 'KULCAI'
agent    "5% от тарифа для иных международных рейсов MS"
subagent "3,5% от тарифа для иных международных рейсов MS"
international
ticketing_method "aviacenter"
discount "3%"
commission "5%/3.5%"

example 'caihrg'
agent    "0% от тарифа на рейсы MS внутри Египта"
subagent "0% от тарифа на рейсы MS внутри Египта"
domestic
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

example 'caisvo svocai/su'
agent    "0% от тарифа на все иные сектора авиабилетов Interline"
subagent "0% от тарифа на все иные сектора авиабилетов Interline"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "MU", "CHINA EASTERN", start_date: "15.09.2011"
########################################

example 'svohkg/business'
example 'svohkg/business hkgmfm/business'
example 'svotsa/business'
example 'svotsa/business tsahkg/business'
example 'svotpe/business'
agent "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 9%"
subagent "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 7%"
classes :business
check %{ includes(country_iatas, %W(TW HK MO)) }
ticketing_method "aviacenter"
discount "7%"
commission "9%/7%"

example 'ledhkg/economy'
example 'ledtsa/economy'
example 'ledtpe/economy'
agent "MU междунар или регион-ные* рейсы Экономический  класс – 7%"
subagent "MU междунар или регион-ные* рейсы Экономический класс – 5%"
classes :economy
check %{ includes(country_iatas, %W(TW HK MO)) }
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'ledhkg/economy hkgled/business'
agent "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 7%"
subagent "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 5%"
classes :economy, :business
check %{ includes(country_iatas, %W(TW HK MO)) }
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svohkg hkgsvo/ab'
example 'svomfm/ab mfmsvo'
agent "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 5%"
subagent "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 3%"
interline :yes
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

example 'shacan'
agent "MU только внутр. перелет по территории КНР – 1 EUR"
subagent "MU только внутр. перелет по территории КНР – 5 руб"
domestic
ticketing_method "aviacenter"
consolidator "2%"
commission "1eur/5"

example 'svohkg/ab'
agent "Рейсы Других авиакомпаний  – 1 EUR"
subagent "Рейсы Других авиакомпаний – 5 руб"
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
commission "1eur/5"

carrier "NN", "VIM-Airlines"
########################################

example 'svocdg/c cdgsvo/d'
agent "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
discount "2.5%"
subclasses "CD" # это у NN — бизнес-класс
ticketing_method "aviacenter"
commission "5%/3.5%"

example 'svocdg cdgsvo'
agent "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3.5%"

example 'svocdg/ab cdgsvo'
agent "Интерлайн не прописан"
subagent "Интерлайн не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0"

carrier "NZ", "AIR NEW ZEALAND (НЕ BSP!!!)"
########################################

example 'svocdg cdgsvo'
agent    "7% от тарифа на международные перелеты на рейсы NZ;"
subagent "5% от тарифа на международные перелеты на рейсы NZ;"
international
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'dudbhe bhedud'
agent    "5% от тарифа на внутренние перелеты на рейсы NZ."
subagent "3,5% от тарифа на внутренние перелеты на рейсы NZ."
domestic
ticketing_method "aviacenter"
discount "3%"
commission "5%/3.5%"

carrier "OA", "OLYMPIC AIR (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собственные рейсы OA (В договоре Interline не прописан.)"
subagent "5 руб. с билета по опубл. тарифам на собств.рейсы OA"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example 'cdgsvo svocdg/ab'
agent "1% от опубл. тарифов на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example 'cdgsvo/ab svocdg/ab'
no_commission

carrier "OK", "CZECH AIRLINES"
########################################
example 'svocdg'
example 'cdgsvo svocdg/ab'
agent "1% от опубл. тарифов на собств.рейсы OK;"
agent "1% от опубл. тарифов на рейсы Interline, если один из сегментов выполнен под кодом OK."
subagent "0.5%"
interline :no, :yes
ticketing_method "aviacenter"
discount "1%"
commission "1%/0.5%"

carrier "OS", "AUSTRIAN AIRLINES"
########################################

example 'svojfk/f'
example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
discount "6%"
commission "10%/8%"

example 'svojfk/q'
example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
discount "4%"
commission "8%/6%"

example 'svojfk/y'
example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
discount "1.5%"
commission "5%/3%"

example 'dmebcn'
example 'bcndme dmebcn/lh'
agent    "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS.
(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
check %{includes(country_iatas, 'ES FR IT CZ PT NL CH') }
interline :no, :yes
ticketing_method "aviacenter"
our_markup "10"
## discount '5%'
commission "1/0.05"

example 'svooko'
example 'svooko okosvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS.
(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0"
# discount "1.5%"
commission "1/0.05"

example 'cdgsvo/ab'
no_commission

carrier "OU", "CROATIA AIRLINES  (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы OU"
subagent "0,5% от опубл. тарифа на собств.рейсы OU"
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на рейсы Interline с участком OU."
subagent "0,5% от опубл. тарифа на рейсы Interline с участком OU."
interline :yes
ticketing_method "aviacenter"
commission "1%/0.5%"

example 'cdgsvo/ab'
no_commission

carrier "OV", "ESTONIAN AIR  (РИНГ АВИА)"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от всех опубл. тарифов на рейсы OV (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы OV"
interline :no, :unconfirmed
ticketing_method "aviacenter"
## discount "0.5%"
#our_markup "60"
commission "1%/0.5%"

carrier "PG", "BANGKOK AIRWAYS (Тальавиэйшн)"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "5% от всех опубл. тарифов на рейсы PG (В договоре Interline не прописан.)"
subagent "3,5% от опубликованных тарифов на рейсы PG"
interline :no, :unconfirmed
ticketing_method "aviacenter"
discount "4%"
commission "5%/3.5%"

carrier "PS", "Ukraine International Airlines (ГЛОНАСС)", start_date: "20.06.2013"
########################################

example 'svocdg'
example 'svocdg cdgsvo'
agent "Для перевозок, содержащих участок в/из пунктов РФ:
5% (3%) (3%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в Москвы;"
subagent ""
check %{ includes(country_iatas, 'RU') and includes(city_iatas, 'MOW') }
ticketing_method "aviacenter"
discount "4%"
commission "5%/3%"

example 'ledcdg'
example 'ledcdg cdgled'
agent "7% (5%) (5%) от тарифа Эконом класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) при наличии участков из/в пунктов в РФ, кроме Москвы;"
subagent ""
check %{ includes(country_iatas, 'RU') and not includes(city_iatas, 'MOW') }
ticketing_method "aviacenter"
discount "6%"
commission "7%/5%"

example 'svocdg/business'
example 'svocdg/business cdgsvo/business'
agent    "9% (7%) (7%) от тарифа Бизнес класса на собств. и совместных рейсах Авиакомпании под кодом PS (566) из/в пунктов в РФ;"
subagent ""
classes :business
check %{ includes(country_iatas, 'RU') }
important!
ticketing_method "aviacenter"
discount "9%"
commission "9%/8.5%"

example 'cdgsvo svocdg/ab'
agent "5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent "3% от опубл. тарифов на рейсы Interline c обязательным участком PS"
interline :yes
check %{ includes(country_iatas, 'RU') }
ticketing_method "aviacenter"
discount "4%"
commission "5%/3%"

example 'cdgsvo/ab'
agent "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
check %{ includes(country_iatas, 'RU') }
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

# для несодержащих РФ перевозок

example 'ievcdg'
agent "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на собственных и совместных рейсах Авиакомпании под кодом PS (566)"
subagent "5 р"
check %{ not includes(country_iatas, 'RU') }
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example 'cdgiev ievcdg/ab'
agent "1% (5 руб+2%сбор АЦ) (скидки нет) от тарифа на рейсы Interline с участком PS;"
subagent "5р + 2% сбор ац"
interline :yes
check %{ not includes(country_iatas, 'RU') }
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

example 'cdgiev/ab'
agent "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
check %{ not includes(country_iatas, 'RU') }
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "QF", "QANTAS AIRWAYS (не BSP!!!)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на рейсы QF (В договоре Interline не прописан.)"
subagent "4,9% от опубл. тарифов на рейсы QF"
interline :no, :unconfirmed
ticketing_method "aviacenter"
disabled "not bsp"
commission "7%/4.9%"

carrier "QR", "QATAR AIRWAYS", start_date: "01.06.2013"
########################################

example 'cdgpek/business pekcdg/business'
agent    "от опубл. тарифов, а также от опубл. IT гросс тарифов (искл.групповые тарифы) на собств.рейсы QR: 5% Бизнес класс"
subagent "3,5% от опубл. тарифов на собственные рейсы QR"
classes :first, :business
ticketing_method "aviacenter"
discount "2.7%"
commission "5%/3.5%"

example 'cdgpek/economy pekcdg/economy'
example 'cdgpek/business pekcdg/economy'
agent    "0.1% Эконом класса, а также при различной комбинации Бизнес/Эконом"
subagent "5 коп. с билета Эконом класса, а также при различной комбинации Бизнес/Эконом;"
ticketing_method "aviacenter"
consolidator "2%"
commission "0.1%/0.05"

# dtt
example 'jfksvo'
example 'jfkled ledcdg'
agent    "с сегодня на QR если в маршруте есть Россия (OW/RT, origin/destination) - агентская 5%"
subagent "у нас 3%"
check %{ includes(country_iatas, 'RU') }
ticketing_method "downtown"
tour_code "USAN002"
important!
discount "2%"
commission "5%/3%"

example 'svocdg cdgsvo/ab'
agent    "0.1% на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
subagent "5 коп на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "0.1%/0.05"

example 'cdgsvo/ab'
no_commission

carrier "RB", "SYRIAN ARAB AIRLINES"
########################################

#example 'svocdg'
agent    "7% от всех опубл. тарифов на рейсы RB (В договоре Interline не прописан.)"
subagent "5% от опубл. тарифов на рейсы RB"
## discount "4%"
disabled "Катя сказала выключить, потому что война"
ticketing_method "aviacenter"
commission "7%/5%"

#example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
## discount "4%"
disabled "Катя сказала выключить, потому что война"
ticketing_method "aviacenter"
commission "7%/5%"

carrier "S4", "SATA INTERNACIONAL (РИНГ АВИА)"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от всех опубл. тарифов на собств.рейсы S4 (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы S4"
interline :no, :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "SA", "South African Airways"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на собств. рейсы. SA и рейсы Interline"
subagent "0,5% от опубл. тарифа на собств. рейсы SA и рейсы Interline"
interline :no, :yes
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "SK", "SAS"
########################################

example 'svojfk'
example 'svojfk jfksvo/sk'
agent    "через DTT из России в США и наоборот - 12%"
subagent "через DTT из России в США и наоборот - 10%"
check %{includes(country_iatas, 'US CA') }
subclasses "CDYSEHM"
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0"
discount '8.5%'
ticketing_method "downtown"
commission "12%/10%"

example 'svojfk/Q'
example 'svojfk/Q jfksvo/sk/Q'
agent    "через DTT из России в США и наоборот - 8%"
subagent "через DTT из России в США и наоборот - 6%"
check %{includes(country_iatas, 'US CA') }
#subclasses "JZBQVWKLT"
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0"
discount '4.3%'
ticketing_method "downtown"
commission "8%/6%"

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета на рейсы SAS. (Билеты «Интерлайн» под кодом Авиакомпании могут быть выписаны только в случае существования опубл. тарифов и только при условии, если Авиакомпания выполняет хотя бы один рейс.)"
subagent "50 коп. с билета на рейсы SAS"
interline :no, :yes
ticketing_method "aviacenter"
our_markup "0.5%"
commission "1/0.5"

carrier "SN", "BRUSSELS AIRLINES"
########################################

example 'svojfk/f'
example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
discount "6%"
commission "10%/8%"

example 'svojfk/q'
example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
discount "4%"
commission "8%/6%"

example 'svojfk/y'
example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
discount "1.5%"
commission "5%/3%"

example 'svocdg'
example 'DMEBRU'
example 'BRULBA'
agent    "0,5% от опубл. тарифам на собств. рейсы SN;"
subagent "5 руб. с билета по опубл. тарифам на собств. рейсы SN;"
ticketing_method "aviacenter"
our_markup "10"
commission "0.5%/5"

example 'svocdg cdgsvo/ab'
agent    "0,5% от опубл. тарифам в случае применения совмещенного тарифа авиакомпаний;"
subagent "5 руб. с билета по опубл. тарифам в случае применения совмещенного тарифа авиакомпаний;"
interline :yes
ticketing_method "aviacenter"
our_markup "60"
commission "0.5%/5"

carrier "SQ", "SINGAPORE AIRLINES (Авиарепс)"
########################################

example 'svosin'
agent    "3% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
subagent "2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
# interline :no, :yes
check %{ includes(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
discount "1.5%"
commission "3%/2%"

example 'svohou houmia'
example 'housvo'
agent    "6% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
subagent "4,2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
important!
# interline :no, :yes
check %{ (includes(country_iatas.first, 'RU') and includes(city_iatas, 'HOU')) or 
  (includes(city_iatas.first, 'HOU') and includes(country_iatas.last, 'RU')) }
ticketing_method "aviacenter"
discount "4.2%"
commission "6%/4.2%"

example 'miahou housvo'
example 'sinsvo'
example 'housvo svosin'
example 'sinsvo svosin/su'
agent    "3% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
agent    "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
subagent "2% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
subagent "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
interline :no, :yes
ticketing_method "aviacenter"
discount "1.5%"
commission '3%/2%'

carrier "SW", "AIR NAMIBIA (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы SW (В договоре Interline отдельно не прописан.)"
subagent "5руб от опубл. тарифов на собств.рейсы SW"
interline :no, :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "TG", "THAI AIRWAYS"
########################################

example 'svobkk'
agent "С 01.02.2011г. 5% от всех опубл.и конфиденциальных тарифов на международные рейсы TG"
subagent "С 01.02.2011г. 3% от опубл. и конфиде.тарифов на международные рейсы TG"
international
ticketing_method "aviacenter"
discount "4%"
commission "5%/3%"

example 'bkkdmk'
agent "С 01.02.2011г. 0% от всех опубл. тарифов на внутренние рейсы TG"
subagent "С 01.02.2011г. 0% от опубл.тарифов на внутренние рейсы TG"
domestic
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

example 'svobkk/su bkkdmk'
agent "0% от тарифов на рейсы Interline. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
subagent "0% от опубл. тарифа на рейсы Interline с участком TG. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "TK", "TURKISH AIRLINES", start_date: '17.03.2013'
########################################

example 'istsvo svoist'
agent    "7% от полного опубл. тарифа IATA на рейсы TK;"
agent    "+ 7% от тарифа Эконом класса на рейсы TK;"
subagent "5% от тарифа экономического класса на рейсы TK;"
discount "6%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svoist/business"
agent "12% от тарифа Бизнес класса на рейсы TK с вылетом из РФ"
subagent "нет? ставлю 10%"
classes :business
check %{ includes(country_iatas.first, 'RU') }
discount "11%"
important!
ticketing_method "aviacenter"
commission "12%/10%"

example "miaist/business"
agent "7% от тарифа Бизнес класса на рейсы TK с вылетом не из РФ (кроме перелетов внутри Турции);"
subagent "нет? ставлю 5%"
classes :business
check %{ not includes(country_iatas.first, 'RU') and not includes_only(country_iatas, 'TR') }
discount "6%"
important!
ticketing_method "aviacenter"
commission "7%/5%"

example 'istank'
example 'istank/business'
agent    "5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
subagent "3,5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
important!
domestic
classes :business, :economy
ticketing_method "aviacenter"
discount "5%"
commission "5%/3.5%"

example 'svoist istsvo/ab'
agent    "Как обычная 7% (Билеты «Интерлайн» под кодом TK могут быть выписаны только в случае существования опубл. тарифов и только при условии, если TK выполняет первый рейс)"
subagent "Как обычная 5%"
interline :first
ticketing_method "aviacenter"
discount "6%"
commission "7%/5%"

carrier "TP", "TAP PORTUGAL"
########################################

example 'svocdg cdgsvo'
agent    "1% от опубл. тарифов на собств. рейсы TP и рейсы Interline"
subagent "0,5% от опубл. тарифа на собственные рейсы TP и рейсы Interline"
interline :no, :yes
ticketing_method "aviacenter"
# discount "0.5%"
commission "1%/0.5%"

carrier "UA", "UNITED AIRLINES (ГЛОНАСС)", start_date: "2013-06-20"
########################################

# внутренние
example 'jfklax'
agent "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде"
subagent ""
domestic
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

# Сша/Канада, Американский континент
example 'jfksvo'
example 'jfksvo svojfk'
example 'yowjfk'
example 'yowsvo'
agent "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде;"
subagent ""
check %{ includes_only(country_iatas.first, "US CA") }
international
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

example 'svocdg/lh cdgjfk jfkcdg/lx cdgsvo'
agent "5% (3%) (3%) на все опубл. тарифы Эконом класса во всех подклассах бронирования из России в США, Канаду и Латинскую Америку с перелетом из России в Европейские города авиакомпаниями, входящими в LH Group ( LH,LX,SN) , и трансатлантическим перелетом авиакомпанией United под кодом UA. Обратный перелет также должен быть строго в этой комбинации. (0% если начало путешествия на UA будет из Европы)."
agent "Проездной документ должен быть оформлен единым билетом на стоке 016."
subagent "3%"
classes :economy
check %{ includes_only(operating_carrier_iatas.first, 'LH LX SN') and includes(operating_carrier_iatas.second, 'UA') and includes(country_iatas.first, 'RU') } # вроде так проверяем трансатлантику у VS, например
ticketing_method "aviacenter"
consolidator "2%"
discount "3%"
disabled "ведь по dtt продаем же"
commission "5%/3%"

example 'svocdg/lh/f cdgjfk/a jfkcdg/lx/c cdgsvo/z'
agent "7% (5%) (5%) в следующих подклассах бронирования: F/A/J/C/D/Z на все опубл. тарифы из России в США, Канаду и Латинскую Америку с перелетом из России в Европейские города авиакомпаниями, входящими в LH Group (LH,LX,SN) , и трансатлантическим перелетом авиакомпанией United под кодом UA. Обратный перелет также должен быть строго в этой комбинации. (0% если начало путешествия на UA будет из Европы)."
agent "Проездной документ должен быть оформлен единым билетом на стоке 016."
subagent "5%"
subclasses "FAJCDZ"
check %{ includes_only(operating_carrier_iatas.first, 'LH LX SN') and includes(operating_carrier_iatas.second, 'UA') and includes(country_iatas.first, 'RU') } # вроде так проверяем трансатлантику у VS, например
ticketing_method "aviacenter"
consolidator "2%"
discount "5%"
disabled "ведь по dtt продаем же"
commission "7%/5%"

example 'svojfk/f'
example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
international
tour_code "815ZU"
designator "PP10"
discount "6%"
commission "10%/8%"

example 'svojfk/q'
example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
international
tour_code "815ZU"
designator "PP8"
discount "4%"
commission "8%/6%"

example 'svojfk/y'
example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
international
tour_code "815ZU"
designator "PP5"
discount "1.5%"
commission "5%/3%"

carrier "UA", "UNITED AIRLINES (ГЛОНАСС)", start_date: "2014-01-01"
########################################

# внутренние
example 'jfklax'
agent "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде"
subagent ""
domestic
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

# Сша/Канада, Американский континент
example 'jfksvo'
example 'jfksvo svojfk'
example 'yowjfk'
example 'yowsvo'
agent "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде;"
subagent ""
check %{ includes_only(country_iatas.first, "US CA") }
international
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

example 'svojfk/f'
example 'svojfk/a jfksvo/z'
agent    "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
check %{ includes_only(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
international
tour_code "815ZU"
designator "PP10"
discount "6%"
commission "10%/8%"

example 'svojfk/q'
example 'svojfk/q jfksvo/k'
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
check %{ includes_only(country_iatas, %W[TR AE BH IL KW QA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
international
tour_code "815ZU"
designator "PP8"
discount "4%"
commission "8%/6%"

example 'svojfk/y'
example 'svojfk/y jfksvo/m'
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
check %{ includes(country_iatas, %W[AT CH DE FR IT NL ES GB IE BE DK FI GR LU NO PT SE TR AE BH IL KW QA BA BG CY CZ HR HU MD ME MK MT PL RO RS SI SK AL AM AZ BY EE GE KG KZ LT LV RU TM UA UZ XU AF IQ JO LB OM SA SY YE AO BF BJ CD CG CI CM CV DJ DZ ER GA GH GM GN GQ GW LR LY MA MG ML MU MW MZ NA NG SC SL SN SS ST TG TN ZA ZM ZW BD LK MV PK EG IR BI ET KE RW SD TZ UG US]) and includes(country_iatas, 'US') }
ticketing_method "downtown"
international
tour_code "815ZU"
designator "PP5"
discount "1.5%"
commission "5%/3%"

carrier "UL", "SRI LANKAN AIRLINES"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от всех опубл. тарифов на собств. рейсы UL (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы UL"
interline :no, :unconfirmed
ticketing_method "aviacenter"
# discount "0.5%"
commission "1%/0.5%"

carrier "UX", "Air Europa"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "5% от всех опубл. тарифов на рейсы UX (В договоре Interline отдельно не прописан.)"
subagent "3,5% от опубл. тарифов на собств. рейсы UX"
interline :no, :unconfirmed
ticketing_method "aviacenter"
# discount "3.5%"
commission "5%/3.5%"

carrier "VN", "VIETNAM AIRLINES", start_date: "01.09.2012"
########################################

example 'svohan hansvo'
agent    "C 01.09.12г. 3% от опубл. тарифов на междунар.рейсах VN;"
subagent "2% от опубл. тарифов на междунар.рейсах VN;"
international
ticketing_method "aviacenter"
discount "2%"
commission "3%/2%"

example 'hansgn'
agent    "3% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent "2% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
ticketing_method "aviacenter"
discount "2%"
commission "3%/2%"

example 'hansgn/ab sgnhan'
agent "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent "C 01.09.12г. 0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "0%/0%"

carrier "VS", "Virgin Atlantic Airways Limited (ГЛОНАСС)"
########################################

example 'svocdg cdgsvo'
agent    "7% от опубл. тарифов на собств. рейсы VS"
subagent "5% от опубл. тарифов на собств.рейсы VS"
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svolhr/ba lhrcce'
agent    "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :yes
# FIXME надо ли проверять трансатлантику?
check %{ includes(%W(UN BA SU), marketing_carrier_iatas.first) and includes(marketing_carrier_iatas.second, 'VS') }
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
no_commission

carrier "VV", "AEROSVIT", start_date: "01.08.2012"
########################################

example 'leddok'
example 'ledcdg'
agent "9% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV"
subagent "8,5% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV."
check %{ includes(country_iatas.first, 'RU') and not includes(city_iatas.first, 'MOW') and not includes(city_iatas.last, 'IEV') }
ticketing_method "aviacenter"
discount "7%"
disabled "bankrupt"
no_commission "9%/8.5%"

example 'svokbp/business kbpsvo/business'
agent "9% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
classes :business
check %{ (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'IEV')) or (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'MOW') and includes(city_iatas, 'IEV')) }
ticketing_method "aviacenter"
discount "3%"
disabled "bankrupt"
no_commission "5%/4.5%"

example 'svokbp kbpsvo'
agent "7% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
check %{ (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'IEV')) or (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'MOW') and includes(city_iatas, 'IEV')) }
ticketing_method "aviacenter"
discount "3%"
disabled "bankrupt"
no_commission "5%/4.5%"

example 'kbpdok'
example 'kbptbs'
example 'tbstlv'
agent "1% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
subagent "5 рублей от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
check %{ not includes(country_iatas.first, 'RU') }
ticketing_method "aviacenter"
our_markup "60"
consolidator "2%"
disabled "bankrupt"
no_commission "1%/5"

example 'kbpsvo/ab svokbp'
agent "5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
subagent "4,5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
interline :yes
ticketing_method "aviacenter"
discount "3%"
disabled "bankrupt"
no_commission "5%/4.5%"

example 'kbpsvo/ab svokbp/ab'
agent "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
subagent "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
disabled "bankrupt"
no_commission "0%/0%"

example 'svosip'
example 'svoods'
check %{includes(city_iatas, 'SIP ODS')}
interline :no, :yes, :absent
important!
disabled "bankrupt"
no_commission "Катя просила выключить срочно от 14.06.12"

carrier "WY", "OMAN AIR"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств. рейсы WY (В договоре Interline не прописан.)"
subagent "3% от опубл. тарифа на собств.рейсы WY"
ticketing_method "aviacenter"
discount "1.5%"
commission "5%/3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "XW", "SkyExpress Limited", start_date: "01.10.2011"
########################################

example 'svocdg'
agent    "С 01.10.11г.  5 (пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании;"
subagent "С 11.04.11г. 5% от всех опубл. тарифов на собств. рейсы XW;"
interline :no
ticketing_method "aviacenter"
disabled "no license"
commission "5%/5%"

example 'svocdg cdgsvo/gw'
agent     "С 01.10.11г. 3 (три) % от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) - как с участием, так и без участия собственных рейсов SkyExpress Limited Company (ЗАО “Небесный Экспресс”) (XW/492);"
subagent "С 11.04.11г. 3% от всех опубл. тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) – с/без участия собств. рейсов XW;"
interline :yes
check %{ includes_only(marketing_carrier_iatas, %W[XW GW]) }
ticketing_method "aviacenter"
disabled "no license"
commission "3%/3%"

example 'svopee peesvo/xf'
agent "С 11.04.11г. 1 (Один) Рубль РФ от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) - как с участием, так и без участия"
subagent "С 11.04.11г. 5 коп с билета по опубл. тарифам на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) – с/без участия собств. рейсов XW."
interline :yes
check %{ includes_only(marketing_carrier_iatas, %W[XF GW]) }
ticketing_method "aviacenter"
consolidator "2%"
disabled "no license"
commission "1/0.05"

carrier "YM", "MONTENEGRO AIRLINES"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "8% от всех опубл. тарифов на рейсы YM (В договоре Interline не прописан.)"
subagent "6% от всех опубл. тарифов на рейсы YM"
interline :no, :unconfirmed
ticketing_method "aviacenter"
discount "7%"
commission "8%/6%"

carrier "YO", "Heli air Monaco (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1 руб. с билета на все виды тарифов (В договоре Interline не прописан.)"
subagent "50 коп. с билета на рейсы YO"
interline :no, :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.5"

carrier "ZI", "AIGLE AZUR (РИНГ-АВИА)"
########################################

example 'svocdg/i'
agent    "11% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subagent "9% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subclasses "IDJC"
ticketing_method "aviacenter"
discount "9%"
commission "11%/9%"

example 'svocdg/k'
agent "7% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subagent "5% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subclasses "MKONXHBYSW"
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svocdg/q'
agent "3% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subagent "2% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subclasses "TQUVL"
ticketing_method "aviacenter"
discount "2%"
commission "3%/2%"

example 'cdgsvo/un'
example 'cdgsvo svocdg/un'
agent "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
subagent "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
interline :yes
check %{ includes_only(marketing_carrier_iatas, 'UN  ZI') }
ticketing_method "aviacenter"
disabled "Система не дает интерлайн"
consolidator "2%"
commission "0%/0%"

carrier "J2", "Azerbaijan Hava Yollari"
########################################

example 'svocdg'
agent    "1 рубль за 1 выписанный билет на стоке 771"
subagent "5 коп. с билета по опубл тарифам на собств. рейсы J2"
disabled "Выключил азеров, т.к. их нет в BSP"
ticketing_method "aviacenter"
consolidator "2%"
disabled "no etkt"
commission "1/0.05"

carrier "AT", "ROYAL AIR MAROC"
########################################

example 'svocdg'
agent "5% от опубл. тарифов Эконом класса на собств. рейсы АТ"
subagent "3% от опубл. тарифов Эконом класса на собств. рейсы АТ"
classes :economy
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

example 'svocdg/business'
agent "7% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
subagent "5% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
classes :business
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
interline :yes, :absent
no_commission

carrier "NX", "AIR MACAU"
########################################

example 'svocdg'
agent "5 % от всех опубл. тарифов на собственные рейсы NX"
subagent "3% от всех опубл. тарифов на собственные рейсы NX"
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

carrier "U6", "ОАО Авиакомпания  УРАЛЬСКИЕ  АВИАЛИНИИ", start_date: "01.04.2013"
########################################

example 'svocdg/business cdgsvo/business'
agent "7% от суммы тарифов всех подклассов Бизнес класса обслуживания, полученной от продажи международных перевозок (дальнее зарубежье)"
subagent "5% от суммы тарифов всех подклассов Бизнес класса обсл., полученной от продажи международных перевозок (дальнее зарубежье);"
classes :business
international
ticketing_method "aviacenter"
discount "6%"
commission "7%/5%"

example 'svocdg cdgsvo'
agent "5% от суммы тарифов всех подклассов Эконом класса обслуживания, полученной от продажи международных перевозок (дальнее зарубежье)"
subagent "3% от суммы тарифов всех подклассов Эконом класса обсл., полученной от продажи международных перевозок (дальнее зарубежье)"
international
ticketing_method "aviacenter"
discount "4%"
commission "5%/3%"

# Россия СНГ и Грузия
example 'svotbs'
example 'tbsiev'
agent "5% от тарифов перевозок по России, СНГ и Грузии всех подклассов и классов обслуживания (за исключением маршрутов Групп А и Б)."
subagent "3% от тарифов перевозок по СНГ и Грузии всех подклассов и классов обслуживания (за искл. маршрутов Групп А и Б)"
check %{ includes_only(country_iatas, 'RU AZ AM BY KZ KG MD TJ TM UZ UA GE') }
important!
ticketing_method "aviacenter"
discount "4%"
commission "5%/3%"

# интерлайны

example 'svocdg/ab cdgsvo'
agent "3% от примененных тарифов на сегментах перевозки рейсов интерлайн-партнеров U6 ( наличие участка U6 в билете обязательно)"
subagent "1% от примененных тарифов на рейсы интерлайн-партнеров U6 (наличие участка U6 в билете обязательно)"
interline :yes
check %{ not includes(operating_carrier_iatas, 'NN S7') }
ticketing_method "aviacenter"
discount "2%"
commission "3%/1%"

example 'svocdg/s7 cdgsvo'
agent "10 рублей за каждый участок перевозки, если в перевозке участвуют S7 и NN."
subagent "10 рублей за каждый участок перевозки, если в перевозке участвуют S7 и NN."
interline :yes
check %{ includes(operating_carrier_iatas, 'NN S7') }
ticketing_method "aviacenter"
commission "10/10"

# пункт 3
example 'svocdg/ab cdgsvo/ab'
agent "1 (один) рубль продажа перевозок на рейсы интерлайн-партнеров U6 без участков U6"
subagent "5 коп. продажа перевозок на рейсы интерлайн-партнеров U6 без участков U6"
interline :absent
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

# загадочная хрень
agent "1 (один) рубль за каждый выписанный авиабилет по конфиденциальным IT тарифам."
subagent "5 (пять) руб. за каждый выписанный авиабилет по конфиденциальным IT тарифам."
ticketing_method "aviacenter"
no_commission

# группа А 
example 'ledllk'
example 'svokzn'
example 'kuflbd'
example 'krrovb'
agent "ГРУППА А:"
agent "в размере 0,1%:"
agent "*от суммы тарифов (опубликованных в АСБ) по маршрутам:"
agent "*за каждый взятый с пассажира штраф при оформлении возврата или обмена авиабилетов с взиманием штрафных санкций;"
subagent "c 01.04.2013 г. 50 коп с билета по маршрутам:"
check %{
  includes_only(city_iatas, 'MOW KGD') or
  includes_only(city_iatas, 'MOW KZN') or
  includes_only(city_iatas, 'MOW UFA') or
  includes_only(city_iatas, 'MOW LED') or
  includes_only(city_iatas, 'MOW KUF') or
  includes_only(city_iatas, 'MOW GOJ') or
  includes_only(city_iatas, 'MOW KRR') or
  includes_only(city_iatas, 'MOW AER') or
  includes_only(city_iatas, 'MOW AAQ') or
  includes_only(city_iatas, 'MOW GBB') or
  includes_only(city_iatas, 'MOW BAK') or
  includes_only(city_iatas, 'MOW GDZ') or
  includes_only(city_iatas, 'MOW KVD') or
  includes_only(city_iatas, 'MOW LLK') or
  includes_only(city_iatas, 'MOW SIP') or
  includes_only(city_iatas, 'MOW MRV') or
  includes_only(city_iatas, 'SVX AER') or
  includes_only(city_iatas, 'SVX KZN') or
  includes_only(city_iatas, 'SVX SIP') or
  includes_only(city_iatas, 'SVX KUF') or
  includes_only(city_iatas, 'SVX YKS') or
  includes_only(city_iatas, 'SVX HTA') or
  includes_only(city_iatas, 'SVX AAQ') or
  includes_only(city_iatas, 'SVX UFA') or
  includes_only(city_iatas, 'SVX GDZ') or
  includes_only(city_iatas, 'SVX EVN') or
  includes_only(city_iatas, 'SVX KHV') or
  includes_only(city_iatas, 'SVX VVO') or
  includes_only(city_iatas, 'SVX KRR') or
  includes_only(city_iatas, 'SVX KJA') or
  includes_only(city_iatas, 'SVX PKC') or
  includes_only(city_iatas, 'SVX BAK') or
  includes_only(city_iatas, 'SVX TBS') or
  
  includes_only(city_iatas, 'LED LWN') or
  includes_only(city_iatas, 'LED LLK') or
  includes_only(city_iatas, 'LED VVO') or
  includes_only(city_iatas, 'LED IKT') or
  includes_only(city_iatas, 'LED KHV') or
  includes_only(city_iatas, 'LED YKS') or

  includes_only(city_iatas, 'KUF DYU') or
  includes_only(city_iatas, 'KUF AAQ') or
  includes_only(city_iatas, 'KUF AER') or
  includes_only(city_iatas, 'KUF LBD') or
  
  includes_only(city_iatas, 'CEK GOJ') or
  includes_only(city_iatas, 'CEK TAS') or
  
  includes_only(city_iatas, 'PEE DYU') or
  includes_only(city_iatas, 'PEE LBD') or

  includes_only(city_iatas, 'UFA LBD') or
  includes_only(city_iatas, 'UFA DYU') or

  includes_only(city_iatas, 'KJA IKT') or
  includes_only(city_iatas, 'KJA MRV') or
  includes_only(city_iatas, 'MRV AER') or
  includes_only(city_iatas, 'SIP GOJ') or
  includes_only(city_iatas, 'EVN GOJ') or
  includes_only(city_iatas, 'EVN KUF') or
  includes_only(city_iatas, 'KRR VVO') or
  includes_only(city_iatas, 'KRR OVB') or
  includes_only(city_iatas, 'GOJ TAS') or
  includes_only(city_iatas, 'GOJ SIP') or
  includes_only(city_iatas, 'GOJ NMA') or
  includes_only(city_iatas, 'IKT PKC')
}
important!
ticketing_method "aviacenter"
consolidator "2%"
commission "0.1%/0.5"

example "svotiv/U63171"
example "tivsvo/U63172"
example "svotiv/U63171 tivsvo/U63172"
agent "0.1% Москва-Тиват; Тиват-Москва; Москва-Тиват-Москва; Тиват-Москва-Тиват (только на рейсы U6 3171/3172);"
subagent "0.5 Москва-Тиват; Тиват-Москва; Москва-Тиват-Москва; Тиват-Москва-Тиват (только на рейсы U6 3171/3172);"
check %{  includes_only(city_iatas, 'MOW TIV') and includes_only(flights.every.full_flight_number, %W(U63171 U63172)) }
important!
ticketing_method "aviacenter"
consolidator "2%"
commission "0.1%/0.5"

# группа Б SPECIAL FOR CHITA
example 'svohta'
agent "ГРУППА Б: 3 (три) % от тарифа по всем подклассам по маршрутам: Москва-Чита; Чита-Москва; Москва-Чита-Москва; Чита-Москва-Чита;"
subagent "1 (Один) % от тарифа по всем подклассам по маршрутам: Москва-Чита; Чита-Москва; Москва-Чита-Москва; Чита-Москва-Чита;"
check %{ includes_only(city_iatas, 'MOW HTA') }
important!
ticketing_method "aviacenter"
# discount "1%"
commission "3%/1%"

carrier "GW", "AIR LINES OF KUBAN"
########################################

example 'svocdg'
agent "5% от опубл. тарифов на собств. рейсы авиакомпании."
subagent "3% от всех опубл. тарифов на собств. рейсы GW"
ticketing_method "aviacenter"
## discount "2.5%"
disabled "bankrupt"
commission "5%/3%"

example 'svocdg cdgsvo/ab'
agent "3% от опубл. тарифов на рейсы Interline c обязательным участием GW. Выписка на рейсы Interline без участка GW запрещена."
subagent "1% от всех опубл. тарифов на собств. рейсы GW"
interline :yes
ticketing_method "aviacenter"
## discount "0.5%"
disabled "bankrupt"
commission "3%/1%"

carrier "CQ", "Czech Connect Airlines"
########################################

example 'svocdg'
agent "6% от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "4% от всех опубл. тарифов на собств. рейсы CQ"
interline :no, :unconfirmed
ticketing_method "aviacenter"
## discount "3.5%"
disabled "Перестали летать"
commission "6%/4%" #первомайский апдейт

carrier "W5", "Airline «MAHAN AIR» (АВИАРЕПС)"
########################################

example 'svocdg'
agent "5 % от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "3% от всех опубл.тарифов на собств. рейсы W5"
disabled "starting from 13 OCT 2011 Mahan Air (W5/537) is suspended from BSP."
interline :no, :unconfirmed
ticketing_method "aviacenter"
commission "5%/3%"

carrier "IZ", "Arkia"
########################################

example 'svocdg'
agent "7% от всех опубл. тарифов; (Interline отдельно не прописан)"
subagent "5% от всех опубл.тарифов на собств. рейсы IZ"
interline :no, :unconfirmed
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

carrier "5L", "AEROSUR (РИНГ АВИА)"
########################################

example 'svocdg'
agent "1% от опубл. тарифов на собств. рейсы 5L"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы 5L"
interline :no, :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "FJ", "AIR PACIFIC LIMITED (РИНГ АВИА)"
########################################

example 'TVUNAN/L NANVLI/Q' #между фиджи и фиджи
example 'suvakl aklsuv/ab'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на короткие расстояния,"
agent "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
subagent "3% от всех опубл.тарифов на собств. рейсы FJ для перевозки на короткие расстояния,"
subagent "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
check %{ includes_only(country_iatas, %W(FJ AU NZ KI MH FM NR PG WS SB TO TV VU CK AS PF GU NC NU NF MP PW)) }
interline :no, :yes
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

example 'suvcdg'
example 'suvcdg cdgsuv/ab'
agent "7% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на дальние расстояния,"
agent "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
subagent "5% от всех опубл.тарифов на собств. рейсы FJ для перевозки на дальние расстояния,"
subagent "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
check %{ includes(country_iatas, 'FJ') }
interline :no, :yes
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

carrier "RC", "ATLANTIC AIRWAYS (РИНГ АВИА)"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании. (Interline отдельно не прописан)"
subagent "3% от всех опубл. тарифов на собств. рейсы RC"
interline :no, :unconfirmed
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

carrier "A3", "AEGEAN AIRLINES S.A"
########################################

example 'scocdg cdgsvo'
agent " 7% для тарифов Экономического класса"
subagent "5% для тарифов Эконом класса"
international
ticketing_method "aviacenter"
discount "6%"
commission "7%/5%"

example 'svocdg/business cdgsvo/business'
agent "9% для тарифов Бизнес класса"
subagent "7% для тарифов Бизнес класса"
classes :business
important!
international
ticketing_method "aviacenter"
discount "8%"
commission "9%/7%"

example 'skgath athskg/business'
agent "Внутренние перелеты: 1% для тарифов Экономического и Бизнес классов"
subagent "5 руб. с билета для тарифов Эконом и Бизнес классов"
classes :economy, :business
domestic
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example 'svocdg cdgsvo/ab'
agent "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0"

carrier "BJ", "NOUVELAIR (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

agent "0% от всех опубл. тарифов на рейсы BJ"
subagent "2% от всех опубликованных тарифов на рейсы BJ"
ticketing_method "aviacenter"
disabled "предательски отменяют сегменты"
commission "0%/2%"

carrier "MD", "AIR MADAGASCAR (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

example 'svocdg'
agent "1 (Один) % от всех опубл. тарифов на собств. рейсы авиакомпании MD"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы MD"
interline :no, :unconfirmed
ticketing_method "aviacenter"
commission "1%/0.5%"

carrier "TN", "AIR TAHITI NUI (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

example 'svocdg'
agent "1 (Один) рубль от всех опубл. тарифов на собств.рейсы авиакомпании TN"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы TN"
interline :no, :unconfirmed
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

carrier "9U", "Air Moldova"
########################################

example 'dmekiv'
agent "5 (пять) % от всех опубликованных тарифов."
subagent "3% от опубл. тарифов на рейсы 9U"
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

carrier "A9", "GEORGIAN AIRWAYS"
########################################

example 'tbsdme'
agent "8 (восемь) % от опубл. тарифа на собств. рейсы авиакомпании А9;"
subagent "6 % от опубл. тарифа на собств. рейсы А9;"
ticketing_method "aviacenter"
discount "6%"
commission "8%/6%"

example 'tbsdme dmetbs/ab'
agent "7 (семь)  % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании  А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение;"
subagent "5 % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение"
interline :yes
ticketing_method "aviacenter"
discount "5%"
commission "7%/5%"

example 'dmetbs/ab'
agent "5 (пять)   % от опубл. тарифа на рейсы Interline без участка А9."
subagent "3 % от опубл. тарифа на рейсы Interline без участка А9."
interline :absent
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

carrier "5H", "Five Fourty Aviation Limited (Fly540)"
########################################

example "svocdg"
agent "5 (пять) % от опубл. тарифов на собств. рейсы 5H"
subagent "3% от опубл. тарифов на собств. рейсы 5H"
ticketing_method "aviacenter"
## discount "2.5%"
commission "5%/3%"

carrier "U9", "Aircompany Tatarstan", start_date: "01.05.2013"
########################################

example 'svocdg/business cdgsvo/business'
agent "4% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent "3% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
classes :business
ticketing_method "aviacenter"
discount "2%"
commission "4%/3%"

example 'svocdg/economy svocdg/economy'
agent "3% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent "2% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
ticketing_method "aviacenter"
discount "1.5%"
classes :economy
commission "3%/2%"

example 'svocdg/ab cdgsvo'
agent "1% от всех опубл. тарифов на рейсы Interline;"
subagent "5 руб от всех опубл. тарифов на рейсы Interline;"
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

agent "1% от всех опубл. тарифов на рейсы code-share."
subagent "5 руб от всех опубл. тарифов на рейсы code-share;"
not_implemented "не умеем определять code-share"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "RJ", "Royal Jordanian Airline"
########################################

example 'svocdg cdgsvo'
agent "5 (пять) % от всех опубл. тарифов на собств. рейсы RJ"
subagent "3% от опубл. тарифов на собств. рейсы RJ"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

example 'svocdg/ab cdgsvo'
agent "interline нет в договоре"
interline :yes, :absent
no_commission

carrier "TU", "TUNIS AIR"
########################################

example 'svocdg cdgsvo'
agent "3 (три) % от всех опубл. тарифов на собств. рейсы TU"
subagent "2% от всех опубл. тарифов на собств. рейсы TU"
ticketing_method "aviacenter"
discount "1.5%"
commission "3%/2%"

carrier "CM", "COPA AIRLINES"
########################################

example 'svocdg cdgsvo'
agent "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example 'svocdg/ab cdgsvo'
agent "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
interline :yes
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example 'svocdg/ab cdgsvo/ab'
not_implemented

carrier "R3", "Авиакомпания «Якутия»"
########################################

example 'svocdg cdgsvo'
agent "6 % от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
subagent "4% от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
ticketing_method "aviacenter"
discount "3.5%"
commission "6%/4%"

example 'ykscdg/ab cdgyks'
agent "4 % от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами Авиакомпании."
subagent "3% от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами"
interline :yes
ticketing_method "aviacenter"
discount "2.5%"
commission "4%/3%"

carrier "S3", "SANTA BARBARA AIRLINES"
########################################

example 'svocdg cdgsvo'
agent "1 (один) % от всех опубл. тарифов на собств. рейсы S3"
subagent "5 руб. от всех опубл. тарифов на собств. рейсы S3"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "UT", "UTAIR"
########################################

example 'svocdg cdgsvo'
agent "5% DTT"
subagent "3% DTT"
ticketing_method "downtown"
discount "1%"
commission "5%/4%"

carrier "S7", "S7 AIRLINES"
########################################

# dtt по невыгодным условиям прямой выписки
# w
#example 'svocdg/w cdgsvo/w'
#start_date "01.04.2013"
#agent "При продаже перевозок по коду бронирования W, оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0,1%"
#subagent "0.1%"
#subclasses "W"
#interline :no_codeshare
#ticketing_method "downtown"
#commission '5%/3.5%'

=begin
example 'svorgk'
example 'rgksvo'
example 'svorgk rgksvo'
example 'ovbsvo svorgk'
example 'ovbhta'
example 'htaovb'
example 'svoovb ovbhta'
example 'ovbaaq'
example 'aaqovb'
example 'svoaaq aaqovb'
example 'svovar'
example 'varsvo'
example 'svovar varsvo'
example 'ovbuud'
example 'uudovb'
example 'svouud uudovb'
example 'ovbuus'
example 'uusovb'
example 'svouus uusovb'
example 'ovbpek'
example 'pekovb'
example 'svopek pekovb'
example 'ovbhkg'
example 'hkgovb'
example 'svohkg hkgovb'
example 'ovbala'
example 'alaovb'
example 'svoala alaovb'
example 'svobtk'
example 'btksvo'
example 'ledbtk btksvo'
example 'iktgdx'
example 'gdxikt'
example 'ledikt iktgdx'
example 'ovbikt'
example 'iktovb'
example 'ledikt iktovb'
example 'omspek'
example 'pekoms'
example 'ledoms omspek'
example 'uudpek'
example 'pekuud'
example 'leduud uudpek'
example 'iktpek'
example 'pekikt'
example 'ledikt iktpek'
example 'svoboj'
example 'bojsvo'
example 'ledsvo svoboj'
example 'svoalc'
example 'alcsvo'
example 'ledsvo svoalc'
example 'svopmi'
example 'pmisvo'
example 'ledsvo svopmi'
example 'svohta'
example 'htasvo'
example 'ledsvo svohta'
example 'sipovb'
example 'ovbsip'
example 'ledsip sipovb'
example 'svospu'
example 'spusvo'
example 'ledsvo svospu'
example 'svopuy'
example 'puysvo'
example 'ledsvo svopuy'
example 'ovbbkk'
example 'bkkovb'
example 'ovbbkk ovbbkk'
example 'ovbhkt'
example 'hktovb'
example 'ovbhkt ovbhkt'
example 'ovbbkk'
example 'bkkovb'
example 'ovbbkk bkkovb'
example 'kjabkk'
example 'bkkkja'
example 'kjabkk bkkkja'
example 'khvbkk'
example 'bkkkhv'
example 'khvbkk bkkkhv'
example 'svotiv'
example 'tivsvo'
example 'svotiv tivsvo'
example 'svosip'
example 'sipsvo'
example 'svosip sipsvo'
example 'svoaer'
example 'aersvo'
example 'svoaer aersvo'
example 'svoaaq'
example 'aaqsvo'
example 'svoaaq aaqsvo'
start_date "01.04.2013"
agent "При продаже перевозок между г. Москва и г. Горно-Алтайск,г. Горно-Алтайск и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Варна,г. Варна и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Чита,г. Чита и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Анапа,г. Анапа и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Улан-Удэ,г. Улан-Удэ и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Южно-Сахалинск,г. Южно-Сахалинск и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пекин,г. Пекин и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Алматы,г. Алматы и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Братск,г. Братск и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Магадан,г. Магадан и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Иркутск,г. Иркутск и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Омск и г. Пекин,г. Пекин и г. Омск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Улан-Удэ и г. Пекин,г. Пекин и г. Улан-Удэ, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Пекин,г. Пекин и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Бургас,г. Бургас и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Аликанте,г. Аликанте и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пальма-де-Мальорка ,г. Пальма-де-Мальорка  и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Чита,г. Чита и г. Москва (C7-117/118), включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Симферополь,г. Симферополь и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сплит,г. Сплит и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пула,г. Пула и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Бангкок,г. Бангкок и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пхукет,г. Пхукет и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Банкок,г. Банкок и
г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Красноярск и г. Банкок,г. Банкок и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Хабаровск и г. Банкок,г. Банкок и
г. Хабаровск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Тиват,г. Тиват и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Симферополь,г. Симферополь и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сочи,г. Сочи и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Анапа,г. Анапа и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
check %{
  (includes(city_iatas, 'MOW') and includes(city_iatas, 'RGK VAR BTK BOJ SPU PUY TIV SIP AER AER AAQ ALC PMI HTA')) or
  (includes(city_iatas, 'OVB') and includes(city_iatas, 'HTA AAQ UUD UUS BJS HKG ALA BKK HKT SIP')) or
  (includes(city_iatas, 'IKT') and includes(city_iatas, 'GDX OVB BJS BKK')) or
  (includes(city_iatas, 'OMS UUD') and includes(city_iatas, 'BJS')) or
  (includes(city_iatas, 'KJA KHV') and includes(city_iatas, 'BKK'))
}
subagent ""
interline :no_codeshare
ticketing_method "downtown"
commission "5%/3.5%"
=end

# w
#example 'svocdg/w/ab:s7 cdgsvo/w'
#start_date "01.04.2013"
#agent "При продаже перевозок по коду бронирования W, оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0,1%"
#subagent "0.1%"
#subclasses "W"
#ticketing_method "downtown"
#commission '0.1%/0.1%'

=begin
example 'svorgk/ab:s7'
example 'rgksvo/ab:s7'
example 'svorgk/ab:s7 rgksvo'
example 'ovbsvo svorgk/ab:s7'
example 'ovbhta/ab:s7'
example 'htaovb/ab:s7'
example 'svoovb/ab:s7 ovbhta'
example 'ovbaaq/ab:s7'
example 'aaqovb/ab:s7'
example 'svoaaq aaqovb/ab:s7'
example 'svovar/ab:s7'
example 'varsvo/ab:s7'
example 'svovar varsvo/ab:s7'
example 'ovbuud/ab:s7'
example 'uudovb/ab:s7'
example 'svouud/ab:s7 uudovb'
example 'ovbuus/ab:s7'
example 'uusovb/ab:s7'
example 'svouus uusovb/ab:s7'
example 'ovbpek/ab:s7'
example 'pekovb/ab:s7'
example 'svopek pekovb/ab:s7'
example 'ovbhkg/ab:s7'
example 'hkgovb/ab:s7'
example 'svohkg hkgovb/ab:s7'
example 'ovbala/ab:s7'
example 'alaovb/ab:s7'
example 'svoala alaovb/ab:s7'
example 'svobtk/ab:s7'
example 'btksvo/ab:s7'
example 'ledbtk btksvo/ab:s7'
example 'iktgdx/ab:s7'
example 'gdxikt/ab:s7'
example 'ledikt iktgdx/ab:s7'
example 'ovbikt/ab:s7'
example 'iktovb/ab:s7'
example 'ledikt iktovb/ab:s7'
example 'omspek/ab:s7'
example 'pekoms/ab:s7'
example 'ledoms omspek/ab:s7'
example 'uudpek/ab:s7'
example 'pekuud/ab:s7'
example 'leduud uudpek/ab:s7'
example 'iktpek/ab:s7'
example 'pekikt/ab:s7'
example 'ledikt iktpek/ab:s7'
example 'svoboj/ab:s7'
example 'bojsvo/ab:s7'
example 'ledsvo svoboj/ab:s7'
example 'svoalc/ab:s7'
example 'alcsvo/ab:s7'
example 'ledsvo/ab:s7 svoalc'
example 'svopmi/ab:s7'
example 'pmisvo/ab:s7'
example 'ledsvo svopmi/ab:s7'
example 'svohta/ab:s7'
example 'htasvo/ab:s7'
example 'ledsvo svohta/ab:s7'
example 'sipovb/ab:s7'
example 'ovbsip/ab:s7'
example 'ledsip sipovb/ab:s7'
example 'svospu/ab:s7'
example 'spusvo/ab:s7'
example 'ledsvo svospu/ab:s7'
example 'svopuy/ab:s7'
example 'puysvo/ab:s7'
example 'ledsvo svopuy/ab:s7'
example 'ovbbkk/ab:s7'
example 'bkkovb/ab:s7'
example 'ovbbkk ovbbkk/ab:s7'
example 'ovbhkt/ab:s7'
example 'hktovb/ab:s7'
example 'ovbhkt ovbhkt/ab:s7'
example 'ovbbkk/ab:s7'
example 'bkkovb/ab:s7'
example 'ovbbkk bkkovb/ab:s7'
example 'kjabkk/ab:s7'
example 'bkkkja/ab:s7'
example 'kjabkk/ab:s7 bkkkja'
example 'khvbkk/ab:s7'
example 'bkkkhv/ab:s7'
example 'khvbkk bkkkhv/ab:s7'
example 'svotiv/ab:s7'
example 'tivsvo/ab:s7'
example 'svotiv tivsvo/ab:s7'
example 'svosip/ab:s7'
example 'sipsvo/ab:s7'
example 'svosip sipsvo/ab:s7'
example 'svoaer/ab:s7'
example 'aersvo/ab:s7'
example 'svoaer aersvo/ab:s7'
example 'svoaaq/ab:s7'
example 'aaqsvo/ab:s7'
example 'svoaaq aaqsvo/ab:s7'
start_date "01.04.2013"
agent "При продаже перевозок между г. Москва и г. Горно-Алтайск,г. Горно-Алтайск и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Варна,г. Варна и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Чита,г. Чита и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Анапа,г. Анапа и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Улан-Удэ,г. Улан-Удэ и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Южно-Сахалинск,г. Южно-Сахалинск и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пекин,г. Пекин и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Алматы,г. Алматы и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Братск,г. Братск и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Магадан,г. Магадан и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Иркутск,г. Иркутск и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Омск и г. Пекин,г. Пекин и г. Омск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Улан-Удэ и г. Пекин,г. Пекин и г. Улан-Удэ, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Пекин,г. Пекин и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Бургас,г. Бургас и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Аликанте,г. Аликанте и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пальма-де-Мальорка ,г. Пальма-де-Мальорка  и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Чита,г. Чита и г. Москва (C7-117/118), включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Симферополь,г. Симферополь и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сплит,г. Сплит и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пула,г. Пула и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Бангкок,г. Бангкок и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пхукет,г. Пхукет и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Банкок,г. Банкок и
г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Красноярск и г. Банкок,г. Банкок и
г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Хабаровск и г. Банкок,г. Банкок и
г. Хабаровск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Тиват,г. Тиват и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Симферополь,г. Симферополь и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сочи,г. Сочи и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Анапа,г. Анапа и
г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
check %{
  (includes(city_iatas, 'MOW') and includes(city_iatas, 'RGK VAR BTK BOJ SPU PUY TIV SIP AER AER AAQ ALC PMI HTA')) or
  (includes(city_iatas, 'OVB') and includes(city_iatas, 'HTA AAQ UUD UUS BJS HKG ALA BKK HKT SIP')) or
  (includes(city_iatas, 'IKT') and includes(city_iatas, 'GDX OVB BJS BKK')) or
  (includes(city_iatas, 'OMS UUD') and includes(city_iatas, 'BJS')) or
  (includes(city_iatas, 'KJA KHV') and includes(city_iatas, 'BKK'))
}
subagent ""
ticketing_method "downtown"
commission "0.1%/0.1%"
=end

# example 'svocdg/ab cdgsvo'
# example 'ledcdg/fv:s7 cdgled'
# start_date "11.06.2013"
# agent "Открыть выписку S7 на билеты код-шеринг и интерлайн в офисе MOWR228FA."
# agent "Агентская комиссия 3%"
# subagent "Субагентская комиссия 3%"
# interline :no, :yes
# ticketing_method "direct"
# our_markup 400
# discount "2.5%"
# commission "3%/3%"

# general dtt для горячей замены
example 'svojfk jfksvo'
agent "1% dtt"
subagent "3.5% dtt"
interline :no_codeshare
ticketing_method "downtown"
important!
discount "2%"
commission "1%/3.5%"

example 'svocdg/ab cdgsvo'
example 'ledcdg/fv:s7 cdgled'
agent "рейсы код-шеринг и интерлайн без комиссии c дополнительным сбором 400 руб за билет"
subagent "0%"
interline :no, :yes
ticketing_method "downtown"
our_markup "400"
commission "0%/0%"

carrier "GA", "GARUDA INDONESIA"
########################################

example 'jogsoq soqjog'
agent "5% (Пять) от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
subagent "3% от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
domestic
ticketing_method "aviacenter"
discount "2%"
commission "5%/3%"

example "jogjed"
example "jogruh"
agent "от всех опубл. тарифов на собств. рейсы GA на международные перелёты зависит от пункта отправления (см. таблицу ниже):
ИНДОНЕЗИЯ: 1 РУБ  - если пункт назначения JED/RUH"
subagent "ИНДОНЕЗИЯ: 5 коп. с билета если пункт назначения JED/RUH"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(JED RUH)) }
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

example "jogsvo"
agent "ИНДОНЕЗИЯ: 7% - если пункт назначения любой город, кроме JED/RUH"
subagent "ИНДОНЕЗИЯ: 5% от тарифа если пункт назначения любой город, кроме JED/RUH"
check %{ includes(country_iatas.first, 'ID') and not includes(city_iatas.last, %W(JED RUH)) }
ticketing_method "aviacenter"
discount "4%"
commission "7%/5%"

example "joghkg"
example "jogkul"
example "jogsin"
agent "1 РУБ - SIN, 1 РУБ - HKG, 1 РУБ - KUL"
subagent "5 коп. с билета - SIN 5 коп. с билета - HKG 5 коп. с билета - KUL"
check %{ includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(SIN KUL HKG)) }
ticketing_method "aviacenter"
important!
consolidator "2%"
commission "1/0.05"

example "okojog"
agent "ЯПОНИЯ: 1 РУБ - все тарифы, кроме GA FLEX/PEX FARES"
subagent "ЯПОНИЯ: 5 коп. с билета - все тарифы, кроме GA FLEX/PEX FARES  -"
check %{ includes(country_iatas.first, 'JP') }
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

#example "okojog"
agent "ЯПОНИЯ: 7% - GA FLEX/PEX FARES"
subagent "ЯПОНИЯ: 5% - GA FLEX/PEX FARES"
check %{ includes(country_iatas.first, 'JP') }
disabled "no subagent... FLEX PEX?"
ticketing_method "aviacenter"
discount "4%"
commission "7%/5%"

example "okoams"
agent "1%  - AMS"
subagent "5 руб. с билета - AMS"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, 'AMS') }
important!
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

example "okoswp"
example "okomel"
example "okoper"
example "okorse"
agent "5%  - SWP, 5%  - MEL/PER/SYD"
subagent "3% -SWP 3% - MEL/PER/SYD"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SWP MEL PER SYD)) }
important!
ticketing_method "aviacenter"
discount "3%"
commission "5%/3%"

example "okossn"
example "okojed"
example "okoruh"
example "okodxb"
agent "7% - SEL, 7% - JED/RUH, 7% - DXB"
subagent "5% - SEL 5% - JED/RUH 5% - DXB"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SEL JED RUH DXB)) }
important!
ticketing_method "aviacenter"
discount "4%"
commission "7%/5%"

example "okobkk"
example "okopek"
example "okosha"
agent "9% - BKK, 9% - BJS/CAN/SHA"
subagent "7% - BKK 7% - BJS/CAN/SHA"
check %{ includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(BKK BJS CAN SHA)) }
important!
ticketing_method "aviacenter"
discount "7%"
commission "9%/7%"

carrier "W2", "FLEXFLIGHT"
########################################

example 'svocdg cdgsvo'
agent "1 руб. от всех опубл. Тарифов"
subagent "0.05 руб. с билета от всех опубл. тарифов"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

carrier "AR", "AEROLINEAS ARGENTINAS (АВИАРЕПС)"
########################################

example 'svocdg cdgsvo'
agent "1% от всех опубл. Тарифов"
subagent "5 руб. с билета от всех опубл. тарифов"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "KR", "AIR BISHKEK"
########################################

agent "5 % от всех опубл. тарифов на собств. рейсы KR"
subagent "3% от всех опубл. тарифов на собств. рейсы KR"
ticketing_method "aviacenter"
discount "2%"
commission "5%/3%"

carrier "DT", "TAAG ANGOLA AIRLINES"
########################################

agent "1% от всех опубл. тарифов на собств. рейсы DT"
subagent "5 руб. от всех опубл. тарифов на собств. рейсы DT"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "OG", "Air Onix Airlines"
########################################

agent "5% от опубл. тарифов на рейсы OG"
subagent "3% от опубл. тарифов на рейсы OG"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

carrier "EN", "Air Dolomiti"
########################################

agent "1% от всех опубл. тарифов"
subagent "5 руб. от всех опубл. тарифов"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "BE", "FLYBE (BE/267)"
#######################################

agent "0,1% от всех опубл. тарифов на собств. рейсы BE"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы BE"
ticketing_method "aviacenter"
consolidator "2%"
commission "0.1%/0.05"

carrier "KQ", "KENYA AIRWAYS LTD (РИНГ АВИА)"
#######################################

agent "1 (Один) % от всех опубл. тарифов на собств. рейсы авиакомпании KQ"
subagent "???"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/1"

carrier "QU", "AIRLINE UTAIR-UKRAINE (РИНГ АВИА)"
#######################################

agent "8% от всех опубл. тарифов на собств. рейсы авиакомпании QU.
Продажа на рейсы интерлайн-партнёров на бланке ООО \"Авиакомпания \"ЮТэйр-Украина\" (QU/761) запрещена."
subagent "6%, ждем настоящих цифр"
ticketing_method "aviacenter"
discount "6%"
commission "8%/6%"

carrier "MR", "HUNNU AIR (MR/861)", start_date: "01.04.2013"
#######################################

agent "3% от всех опубликованных тарифов на собственные рейсы авиакомпании"
subagent "Субагентская для MR будет 2%"
ticketing_method "aviacenter"
commission "3%/2%"

carrier "AH", "Air Algerie (АВИАРЕПС)"
#######################################

agent "5% от всех опубл. тарифов;"
subagent "3% от всех опубл. тарифов"
disabled "PROHIBITED TICKETING CARRIER"
ticketing_method "aviacenter"
commission "5%/3%"

carrier "W3", "ARIK AIR (АВИАРЕПС)"
#######################################

agent "1% от всех опубликованных тарифов"
subagent "5 рублей с билета по опубликованным тарифам"
ticketing_method "aviacenter"
consolidator "2%"
commission "1%/5"

carrier "PK", "Pakistan International Airlines"
#######################################

agent "1 руб от всех опубл тарифов на собств рейсы PK"
subagent "0,05 руб от всех опубл тарифов на собств рейсы PK"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

carrier "BV", "BLUE PANORAMA AIRLINES S.P.A. (АВИАРЕПС)"
#######################################

agent "1EURO (5 РУБ) с билета на рейсы BV +2% сбор АЦ"
subagent "5 руб"
ticketing_method "aviacenter"
consolidator "2%"
commission "1eur/5"

carrier "SZ", "AIR COMPANY SOMON AIR LLC"
#######################################

agent "5% от всех опубл. тарифов на собств. рейсы “AIR COMPANY SOMON AIR LLC” (SZ/413)."
agent "Продажа на рейсы интерлайн-партнёров на бланке “AIR COMPANY SOMON AIR LLC” (SZ/413) запрещена."
subagent "3% от всех опубл. тарифов на собств. рейсы “AIR COMPANY SOMON AIR LLC” (SZ/413)."
subagent "Продажа на рейсы интерлайн-партнёров на бланке “AIR COMPANY SOMON AIR LLC” (SZ/413) запрещена."
ticketing_method "aviacenter"
discount "2.25%"
commission "5%/3%"

carrier "EB", "PULLMANTUR AIR (РИНГ АВИА)"
#######################################

agent "1 руб от всех опубл. тарифов на собств. рейсы"
subagent "0.05 руб от всех опубл. тарифов на собств. рейсы"
ticketing_method "aviacenter"
consolidator "2%"
commission "1/0.05"

carrier "OZ", "ASIANA AIRLINES", start_date: "2013-06-01"
#######################################

agent "агентская комиссия - по 31.12.2013г. 5% от всех опубл.тарифов"
subagent "субагентская комиссия - по 31.12.2013г. 3% от всех опубл.тарифов"
ticketing_method "aviacenter"
discount "2.5%"
commission "5%/3%"

carrier "OZ", "ASIANA AIRLINES", start_date: "2014-01-01"
#######################################

