# encoding: utf-8
class Commission
include CommissionRules

carrier "SU", "Aeroflot"
########################################

example "svocdg"
example "svocdg/business cdgsvo/economy"
agent "1.1.На рейсы под кодом «SU», включая рейсы по соглашению «Код-шеринг» (в том числе по тарифам ИАТА):"
agent "- за продажу в Эконом классе 7 % от тарифа;"
agent "..."
agent "- за переоформление авиабилета с доплатой по тарифу в Эконом классе 7 % от суммы доплаты по тарифу;"
agent "- за переоформление авиабилета с доплатой по тарифу в Бизнес классе 9% от суммы доплаты по тарифу;"
agent "- за продажу при комбинации тарифов Эконом класса и Бизнес класса 7% от тарифа;"
agent "- за переоформление авиабилета с доплатой по тарифу при комбинации тарифов Эконом класса и Бизнес класса 7% суммы доплаты по тарифу."
subagent "1.1. На БСО Перевозчика ОАО «АЭРОФЛОТ – Российские авиалинии», ЕТ или STD BSP комиссионное вознаграждение Субагента при продаже авиаперевозок составит:"
subagent "• на собственные рейсы (в т.ч. по соглашениям «code-share»):"
subagent "5 % от тарифов Эконом класса (в т.ч. при комбинации Эконом и Бизнес классов),   при переоформлении с доплатой по тарифам Эконом класса (в т.ч. при комбинации Эконом и Бизнес классов);"
commission "7%/5%"

#subagent "5 (пять) руб. с авиабилета по специальным тарифам (субсидийным перевозкам) на рейсы авиакомпании SU и необходимым пакетом документов (в т.ч. при переоформлении авиабилета с доплатой по тарифу)."

example "svocdg/business"
important!
agent "- за продажу в Бизнес классе  9 % от тарифа;"
subagent "7 % от тарифов Бизнес класса, при переоформлении с доплатой по тарифам Бизнес класса;"
classes :business
commission "9%/7%"

example "svocdg/su cdgsvo/ab"
agent "1.2. На рейсы других авиакомпаний по соглашениям «Интерлайн» при продаже перевозок в комбинации с рейсом под кодом «SU»:"
agent "- за продажу пассажирских перевозок по сквозным или участковым тарифам –   5 процентов от всего тарифа;"
agent "- при переоформлении авиабилета с доплатой по тарифу –  5  процентов  от суммы доплаты по тарифу."
subagent "• на рейсы Interline в комбинации с рейсом под кодом «SU»:"
subagent "(три) % от сквозных или участковых тарифов (в т.ч. при переоформлении авиабилета с       доплатой по тарифу)"
interline :yes
commission "5%/3%"

agent "- за оформление бесплатных  пассажирских перевозок комиссия не начисляется."
no_commission

example "cdgsvo/ab"
agent "1.3. На рейсы других авиакомпаний по соглашениям «Интерлайн» при продаже перевозок без комбинации с рейсом под кодом «SU»:"
agent "- 1 евро по курсу GDS на день выписки авиабилета) за авиаперевозку  (в рублевом эквиваленте, исчисляемом по расчетному курсу, установленному ОАО «Аэрофлот» на день оформления авиабилета с округлением до целого числа в большую сторону);"
agent "- 1 евро по курсу GDS на день выписки авиабилета) при переоформлении авиабилета с доплатой по тарифу (в рублевом эквиваленте, исчисляемом по расчетному курсу, установленному ОАО «Аэрофлот» на день оформления  авиабилета с округлением до целого числа в большую сторону); "
subagent "• на рейсы Interline без комбинации с рейсом под кодом «SU»:"
subagent "5 (пять) руб. с авиабилета (в т.ч. при переоформлении авиабилета с доплатой по тарифу)."
interline :absent
commission "1eur/5"

carrier "UN", "TRANSAERO"
########################################

example 'AERDME/F DMEAER/C'
agent "11% МВЛ, ВВЛ Класс F (Империал); J, C, D (Бизнес)"
subagent "9 (девять) % от тарифа на рейсы Перевозчика по всем тарифам классов F, J, C, D."
subclasses "FJCD"
commission "11%/9%"

example 'AERDME/Y DMEAER/M'
agent "7% МВЛ. ВВЛ Y, H, M, Q, B, K, O, R, E"
subagent "5  (пять) % от тарифа на рейсы Перевозчика по всем тарифам классов Y, H, M, Q, B, K, O, R, E."
subclasses "YHMQBKORE"
commission "7%/5%"

example 'TLVDME/T DMEJFK/T JFKDME/T DMETLV/T'
example 'AERDME/W DMEAER/W'
agent "3% МВЛ. ВВЛ L, V, X, T, N, I, G, W, U"
subagent "2 % от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U."
subclasses "LVXTNIGWU"
commission "3%/2%"

example 'DMEMIA/FIRST/F MIADME/FIRST/F'
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "9 % от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
important!
check { (city_iatas & %W(NYC MIA BJS)).present? && %W(RU UA KZ UZ).include?(country_iatas.first) }
commission "12%/9%"

example 'svocdg/lh cdgmad/lh'
no_commission

carrier "2U", "SUN D’OR International Airlines (РИНГ-АВИА)"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств. рейсы 2U (В договоре Interline отдельно не прописан.)"
subagent "3,5% от опубл. тарифов на собств. рейсы 2U"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "5%/3.5%"

carrier "5N", "Нордавиа-РА"
########################################

example 'svocdg'
agent    "7% от всех опубл. тарифов на рейсы 5N (В договоре Interline отдельно не прописан.)"
subagent "5% от опубл. тарифов на собств.рейсы 5N"
commission "7%/5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "7%/5%"

carrier "6H", "ISRAIR AIRLINE"
########################################

example 'svocdg'
agent    "С 01.07.11г. 5% от всех опубл. тарифов на рейсы 6H (В договоре Interline отдельно не прописан.)"
subagent "С 01.07.11г. 3% от опубл. тарифов на собств.рейсы 6H"
commission "5%/3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1/0"

carrier "7B", "ATLANT-SOYUZ"
########################################

disabled "Suspension of Moscow Airlines (7B/499)"
example 'svocdg'
agent    "4% от всех опубл. тарифов на cобств. рейсы 7B"
subagent "2,8% от опубл. тарифов на cобств. рейсы 7B"
commission "4%/2.8%"

disabled "Suspension of Moscow Airlines (7B/499)"
example 'cdgsvo svocdg/ab'
agent    "3% от всех опубл. тарифов на рейсы Interline"
subagent "2% от опубл. тарифов на рейсы Interline"
interline :yes
commission "3%/2%"

example 'svocdg/ab'
no_commission

carrier "7D", "DONBASSAERO"
########################################

example 'svocdg'
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на собств. рейсы 7D;"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на интерлайн-перевозки как с участием собственных, так и без участия собственных рейсов (только рейсы интерлайн-партнёров) авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на рейсы Interline с уч. собств. рейсов 7D;"
interline :yes
commission "5%/3.5%"

carrier "7W", "WINDROSE"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на собств.рейсы 7W"
subagent "6,3% от опубл. тарифов на собств.рейсы 7W"
commission "9%/6.3%"

example 'svocdg cdgsvo/ab'
agent    "5% от всех опубл. тарифов на рейсы Interline c участком 7W"
subagent "3,5% от опубл. тарифов на рейсы Interline c участком 7W"
interline :yes
commission "5%/3.5%"

carrier "9W", "JET AIRWAYS (Авиарепс)"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от опубл. тарифов на собств.рейсы 9W"
agent    "1% от опубл. тарифов на рейсы Interline с участком 9W (Выписка без участка 9W запрещена.)"
subagent "0,5% от опубл. тарифа на собств.рейсы 9W"
interline :possible
commission "1%/0.5%"

example 'cdgsvo/ab'
no_commission

carrier "AA", "AMERICAN AIRLINES"
########################################

example 'svocdg'
agent    "1% от опубл. тарифа на собственные рейсы AA, кроме:"
subagent "0,5% от опубл. тарифа на собственные рейсы AA, кроме:"
commission "1%/0.5%"

example 'miaiad'
agent    "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
subagent "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
important!
interline :possible #Решили с Любой включить интерлайн, хотя он и не прописан
check { %W(US CA PR VI).include?(country_iatas.first) }
commission "0%/0%"

agent    "0% от тарифов VUSA, N1VISIT и N2VISIT."
subagent "0% от тарифов VUSA, N1VISIT и N2VISIT."
disabled "ни разу не попадались"
commission "0%/0%"

carrier "AB", "AIR BERLIN"
########################################

example 'svocdg'
agent    "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent "5 коп с билета по опубл. тарифам на рейсы AB"
commission "1/0.05"

example 'cdgsvo svocdg/lh'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1/0.05"

# FIXME - внести это в основное правило для собственных рейсов
example 'svocdg/hg'
interline :absent
check { marketing_carrier_iatas == ['HG'] }
agent    "1 руб с билета по опубл. тарифам на рейсы HG (подразделение)"
subagent "5 коп с билета по опубл. тарифам на рейсы HG (подразделение)"
commission "1/0.05"

example 'svocdg/s7'
no_commission


carrier "AC", "AIR CANADA (НЕ BSP!!!)"
########################################

agent    "7% от опубл. тарифов на рейсы АС из России и Европы;"
subagent "3.5% от опубл. тарифов на рейсы АС из России и Европы;"
disabled "не BSP"
not_implemented
commission "7%/3.5%"

agent    "0% от опубл. тарифов на внутренние рейсы по Канаде, а также на международные рейсы из Канады и США"
subagent "0% от опубл. тарифов на внутренние рейсы по Канаде, а также на международные рейсы из Канады и США"
disabled "не BSP"
not_implemented
commission "0%/0%"

carrier "AF", "AIR FRANCE"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 euro с билета на рейсы AF. Вознаграждение не выплачивается за любые тарифы net."
agent    "(Билеты Interline могут быть выписаны на бланках AF только в случае существования действующего интерлайн соглашения, официально опубл. тарифов и только при условии, если КЛМ или авиакомпания Эр Франс участвуют в одном из сегментов перевозки.)"
subagent "5 руб. с билета от всех опубл. тарифов на рейсы AF"
interline :possible
commission "1eur/5"

example 'cdgsvo/ab'
no_commission

carrier "AM", "AEROMEXICO"
########################################

example "SVOCDG"
# копия для чистых рейсов AM
agent    "9% от всех опубл. тарифов на рейсы AM;"
subagent "7% от опубл. тарифов на рейсы AM"
commission "9%/7%"

example 'SVOCDG/AF/K CDGMEX/Q MEXCDG/Q CDGSVO/SU/W'
agent    "новые тарифы экономического класса в Мексику через Европу:"
agent    "• Q, K, S, M"
agent    "• До Парижа/Мадрида – SU, AF, UX"
agent    "• 9 % комиссии при условии одного трансатлантического рейса в бронировании"
agent    "вместе с SU, AF, UX и на собственные рейсы авиакомпании"
subagent "7% от опубл. тарифов на рейсы AM"
interline :possible
check { country_iatas.first == 'RU' && city_iatas.include?('MEX') }
commission "9%/7%"

#example 'PRGCDG CDGBCN'
# однажды был такой маршрут, но не повторялся // там было много разных, кстати
#no_commission

carrier "AY", "FINNAIR"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета на рейсы AY (Билеты «Интерлайн» под кодом АY могут быть выписаны только в случае использования опубл. тарифов или тарифов ИАТА и только при условии, если АY выполняет хотя бы один рейс при наличии действующих «Интерлайн» соглашений с другими а/к, задействованными в перевозке.)"
subagent "50 коп. с билета на рейсы AY"
interline :possible
commission "1/0.5"

example 'cdgsvo/ab'
no_commission

carrier "AZ", "ALITALIA"
########################################

example 'svocdg'
agent    "1 euro. с билета по опубл. тарифам на собств. рейсы AZ;"
subagent "5 руб. с билета по опубл. тарифам на собств. рейсы AZ;"
commission "1eur/5"

example 'svocdg cdgsvo/ab'
agent    "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
commission "1eur/5"

example 'svocdg/ab cdgsvo'
no_commission

carrier "B2", "Belavia"
########################################

example 'svocdg'
agent    "5% от всех опубл. тарифов на собств. рейсы B2;"
subagent "3,5% от всех опубл. тарифов на собств. рейсы B2;"
commission "5%/3.5%"

agent    "3% от опубл. тарифов на рейсы “SAS” по маршрутам между Данией, Швецией, Норвегией, Гренландией и по внутренним маршрутам Дании, Швеции и Норвегии;"
subagent "2% от опубл. тарифов на рейсы “SAS” по маршрутам между Данией, Швецией, Норвегией, Гренландией и по внутренним маршрутам Дании, Швеции и Норвегии;"
disabled #мощни правило needed
#geo
not_implemented
commission "3%/2%"

agent    "3% от опубл. тарифов на внутренние рейсы РФ авиакомпании “Аэрофлот”;"
subagent "2% от опубл. тарифов на внутренние рейсы РФ авиакомпании “Аэрофлот”;"
disabled #правило
#geo
not_implemented
commission "3%/2%"

agent    "3% от опубл. тарифов Lufthansa на внутренние рейсы Германии;"
subagent "2% от опубл. тарифов Lufthansa на внутренние рейсы Германии;"
disabled #правило
#geos
not_implemented
commission "3%/2%"

agent    "3% от опубл. тарифов LOT Polish Airlines на внутренние рейсы Польши;"
subagent "2% от опубл. тарифов LOT Polish Airlines на внутренние рейсы Польши;"
disabled #правило
#geo
not_implemented
commission "3%/2%"

agent    "3% от опубл. тарифов Alitalia на внутренние рейсы Италии."
subagent "2% от опубл. тарифов Alitalia на внутренние рейсы Италии."
disabled #правило
#geo
not_implemented
commission "3%/2%"

carrier "BA", "BRITISH AIRWAYS (См. в конце таблицы продолжение в 4-х частях)"
########################################

example 'svocdg'
agent    "1 euro с билета по опубл. тарифам на собств. рейсы BA;"
subagent "5 руб. с билета по опубл. тарифам на собств. рейсы BA; Сбор Агента 2% от тарифа."
commission "1eur/5"

example 'svocdg cdgsvo/ab'
agent    "1 euro с билета по опубл. тарифам на рейсы Interline, с участком BA. (British Airways и другие перевозчики (oneworld и авиакомпании имеющие договор interline с British Airways), выписанные на одном бланке. Правило первого перевозчика не является обязательным, то есть первый перелет может быть выполнен другой авиакомпанией. Не  разрешается использование бланков ВА для выписки других перевозчиков (даже авиакомпаний членов альянса oneworld, кроме Qantas) без участия ВА. Нарушение этого правила повлечет за собой ADM на сумму GBP 25."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, с участком BA. Сбор Агента 2% от тарифа."
interline :yes
commission "1eur/5"

carrier "BD", "BMI"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "С   01.02.2011г. 1 руб. с билета по опубл.тарифам на рейсы BD"
subagent "С 01.02.2011г. 5 коп. с билета по опубл. тарифам на собств. рейсы BD и рейсы Interline с участком BD"
interline :possible
commission "1/0.05"

example 'svocdg/ab'
no_commission

carrier "BI", "ROYAL BRUNEY AIRLINES"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы BI (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы BI"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "BT", "AIR BALTIC"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета по всем опубл. тарифам на собств. рейсы BT и рейсы Interline с участком BT"
subagent "50 коп с билета на рейсы BT"
interline :possible
commission "1/0.5"

example 'cdgsvo/ab'
no_commission

carrier "CA", "AIR CHINA"
########################################

#C 05.05.2011 по 31.03.2012г.
#по маршрутам Москва-Пекин или Москва-Пекин-Москва:
example 'svopek/f'
example 'svopek/f peksvo/f'
agent   "20% от опубл. тарифов по классу F на собств. рейсы CA;"
subagent "18,5% от опубл. тарифов по классу F на собств. рейсы CA"
subclasses "F"
check { city_iatas.first == 'MOW' && city_iatas.include?('BJS') }
commission "20%/18.5%"

example 'svopek/c'
example 'svopek/d peksvo/d'
agent   "15% от опубл. тарифов по классам C, D на собств. рейсы СА;"
subagent "13,5% от опубл. тарифов по классам C, D на собств. рейсы СА;"
subclasses "CD"
check { city_iatas.first == 'MOW' && city_iatas.include?('BJS') }
commission "15%/13.5%"

example 'svopek/economy'
example 'svopek/economy peksvo/economy'
agent   "9%   от опубл. тарифов по классам Q и выше на собств. рейсы СА."
subagent "7,5%  от опубл. тарифов по классам Q и выше на собств. рейсы СА."
subagent "YBMHNGKLOQ"
check { city_iatas.first == 'MOW' && city_iatas.include?('BJS') }
commission "9%/7.5"

#другие маршруы
agent   "9% от опубл. тарифов на собств. рейсы CA по маршрутам Москва-Пекин или Москва-Пекин-Москва и далее в третий пункт (кроме класса E и рейсов совместной эксплуатации) или города Китая (классы S, G и выше)."
subagent "7,5% от опубл. тарифов на собств. рейсы CA по маршрутам Москва-Пекин или Москва-Пекин-Москва и далее в третий пункт (кроме класса E и рейсов совместной эксплуатации) или города Китая (классы S, G и выше)."
disabled "не знаю пока как сделать"
commission "9%/7.5%"

agent   "5% от опубл. тарифов CA на все прочие собств. рейсы CA, кроме указанных выше, все рейсы совместной эксплуатации, а также на рейсы из Москвы, Екатеринбурга и Читы;"
subagent "3,5% от опубл. тарифов CA на все прочие собств. рейсы CA, кроме указанных выше, все рейсы совместной эксплуатации, а также на рейсы из Москвы, Екатеринбурга и Читы;"
check { %W(SVX HTA SVO).include?(city_iatas.first) }
disabled "не знаю как работать с совместными рейсами"
commission "5%/3.5%"

agent   "1 EUR с билета по опубл. тарифам на собств. рейсы СА если первый сегмент из России, далее на ресах совместной эксплуатации."
subagent "5 руб. билета по опубл. тарифам на собств. рейсы СА если первый сегмент из России, далее на ресах совместной эксплуатации."
disabled "то же самое"

example 'okopek/ab pekoko'
agent   "0% от опубл. тарифа на рейсы Interline с участком СА; (Interline без участка CA запрещен.)"
subagent "0% от опубл. тарифа на рейсы Interline с участком СА; (Interline без участка   CA запрещен.)"
interline :possible
commission "0%/0%"

example 'cdgpek'
agent   "0% от опубл. тарифа на собств. рейсы СА если первый сегмент не из России;"
subagent "0% от опубл. тарифа на собств. рейсы СА если первый сегмент не из России;"
check { country_iatas.first != 'RU' }
commission "0%/0%"

carrier "CI", "China Airlines"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы CI (В договоре Interline отдельно не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы CI"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0"

carrier "CX", "CATHAY PACIFIC (Тальавиэйшн)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы CX и рейсы Interline c участком СX. Можно выписывать на бланках CX других авиаперевозчиков (при условии действующего интерлайна), если: - хотя бы один перелет совершается авиакомпанией CX,"
agent    "- перелет на другом перевозчике является связующим билетом к основному перелету на авиакомпании CX."
agent    "1 руб. от туроператорских тарифов. (Тарифы можно использовать строго при наличии ваучера у пассажира)."
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "7% от опубл. тарифов на собств. рейсы CX и рейсы Interline c участком СX.      Можно выписывать на бланках CX других авиаперевозчиков (при условии действующего         интерлайна), если: - хотя бы один перелет совершается авиакомпанией CX,"
agent    "- перелет на другом перевозчике является связующим билетом к основному         перелету на авиакомпании CX."
agent    "1 руб. от туроператорских тарифов. (Тарифы можно использовать строго при       наличии ваучера у пассажира)."
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским   тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
interline :possible
commission "7%/5%"

carrier "CY", "CYPRUS AIRWAYS"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на рейсы CY. (В договоре Interline не прописан.)"
subagent "6,3% от опубликованных тарифов на рейсы CY."
commission "9%/6.3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "9%/6.3%"

carrier "CZ", "CHINA SOUTHERN"
########################################

example 'svocdg'
agent    "9% от тарифа на рейсы, полностью выполняемые CZ;"
subagent "6,3% от тарифа на рейсы, полностью выполняемые CZ;"
commission "9%/6.3%"

example 'cdgsvo svocdg/ab'
agent    "7% от тарифа на рейсы CZ с участием других перевозчиков;"
subagent "5% от тарифа на рейсы CZ с участием других перевозчиков;"
interline :yes
commission "7%/5%"


example 'cdgsvo/ab'
agent    "0% от тарифа на рейсы Interline без участка СZ."
subagent "0% от тарифа на рейсы Interline без участка СZ."
interline :absent
commission "0%/0%"

carrier "D9", "ДОНАВИА"
########################################

example 'svocdg/economy'
agent    "7% от опубл. тарифов эконом класса на собств. рейсы D9"
subagent "5% от опубл. тарифов эконом класса на собств. рейсы D9"
classes :economy
commission "7%/5%"

example 'svocdg/business'
agent    "9% от опубл. тарифов бизнес класса на собств. рейсы D9"
subagent "6,3% от опубл. тарифов бизнес класса на собств. рейсы D9"
classes :business
commission "9%/6.3%"

example 'svocdg cdgsvo/ab'
example 'svocdg/business cdgsvo/ab'
agent    "2% от опубл. тарифов на рейсы Interline с участком D9"
subagent "1,4% от опубл. тарифов на рейсы Interline с участком D9"
interline :yes
commission "2%/1.4%"

carrier "DE", "Condor Flugdienst (Авиарепс)"
########################################

example 'svocdg' #date 30.09, с 1.10 — 1 руб
agent    "1% от всех опубл. тарифов на рейсы DE. (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы DE."
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "DL", "DELTA AIRLINES"
########################################

example 'okocdg cdgoko/ab'
example 'cdgoko'
example 'okomia'
#example 'jfkbwi' временно выключен
agent    "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :possible
check { %W(europe asia africa).include?( Country[country_iatas.first].continent ) }
commission "1%/0.5%"

example 'cdgsvo/ab'
agent    "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
commission "1%/0.5%"

example 'EWRDTW DTWYYZ' # ньюйорк - детройт - торонто
agent    "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :possible
check { %W(PR US VI CA).include?(country_iatas.first) }
commission "0%/0%"

example 'svoflu/d flusvo/ab/d'
agent "C 01.07.2011г. по 31.12.2011г."
agent "8% только на собств.рейсы DL Бизнес класса (F, J, C, D, S, I) по направлениям Russian Federation: WORLD , при этом перевозка может быть завершена в европе или китае "
agent "-Если агентство не потребовало комиссию в момент продажи билета, эту комиссию НЕЛЬЗЯ потребовать задним числом позже."
agent "-Комиссия  начисляется, если вся поездка в рамках международного тарифа осуществляется Дельтой."
agent "Уточнение по доп.комиссии от Перевозчика:"
agent "1. Билеты должны иметь надпись “Не подлежат использованию на рейсах других авиакомпаний - возврат оформляется только 'Delta' или перевозчиком, выпускающим билет."
agent "2. Перелёт может быть в одну сторону или туда - обратно. "
agent "3. Скидка, предоставляемая в пунктах продаж, предоставляется, если всё путешествие происходит на Delta. "
agent "4. Скидка, предоставляемая в пунктах продаж, будет рассчитываться по опубликованным тарифам бронирования в классах обслуживания, указанных выше. "
agent "5. Скидка, предоставляемая в пунктах продаж, должна рассчитываться по базовому тарифу без учёта любых сборов  (включая YQ):  аэропортовых сборов, сервисных сборов, пассажирских сборов и других аналогичных сборов. "
agent "ИСКЛЮЧЕНИЯ "
agent "1. Скидки не предоставляются по настоящему договору на следующее:"
agent "o Тарифы для студентов или военнослужащих. "
agent "o Корпоративные скидки."
agent "o Блокировка мест для групп."
agent "o Опубликованные тарифы «Вокруг света»"
agent "o Договорные/Интернет тарифы, опубликованные тарифы, применяемые с кодом тарифа, или любые другие специальные программы тарифов и скидок."
agent "o Раздельный выпуск билета (напр., стыковка билета с вылетом из Мексики с билетом с вылетом из Европы для получения дохода от изменения курса валюты и/или изменений тарифа), не разрешается. "
agent "o Билеты, для оплаты которых или части которых применялась Delta Equity Card/Northwest Barter Card."
subagent "До 31.12.2011г. к стандартной комиссии 5 руб. выплачивается доп.комиссия 5%"
subagent "Доп. комиссия на DL дается строго на собственные рейсы DL c началом путешествия из пунктов РОССИИ по всему миру и по всем классам, кроме Т:"
subagent "-Доп. комиссия выплачивается только с началом перевозки из РОССИИ."
subagent "-Доп. комиссия взимается в дополнение к стандартной комиссии ИАТА 1% в пункте продаж."
subagent "-Если агентство не потребовало комиссию в момент продажи билета, эту комиссию НЕЛЬЗЯ потребовать задним числом позже."
subagent "-Комиссия начисляется, если вся поездка в рамках международного тарифа осуществляется Дельтой."
interline :possible
important!
check { country_iatas.first == 'RU' }
subclasses "FJCDSI"
commission "8%/5%" #+5 рублей мы еще должны получить

carrier "EK", "EMIRATES"
########################################

example 'svocdg/first cdgsvo/business'
example 'svocdg/first cdgsvo/first'
agent    "5% от тарифов Первого и Бизнес классов на рейсы EK;"
subagent "3,5% от тарифов Первого и Бизнес классов на рейсы EK;"
classes :first, :business
commission "5%/3.5%"

example 'svocdg/business cdgsvo'
example 'svocdg/first cdgsvo'
agent    "5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
subagent "3,5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
commission "5%/3.5%"

example 'svocdg'
important!
agent    "1 руб. с билета по опубл.тарифам Эконом класса на рейсы EK."
subagent "5 коп. с билета по опубл.тарифам Эконом класса на собств. рейсы EK."
classes :economy
commission "1/0.05"

agent    "(Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "???"
example 'svocdg cdgsvo/ab'
example 'svocdg/business cdgsvo/ab/business'
interline :half
commission "0/0"

example 'svocdg cdgled/ab ledsvo/ab'
example 'svocdg/ab cdgsvo/ab'
no_commission

carrier "ET", "Ethiopian Airlines Enterprise  (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы ET"
subagent "5% от опубл. тарифов на собств. рейсы ET"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "5 % от опубл. тарифов на рейсы Interline с участком ET"
subagent "3,5 % от опубл. тарифов на рейсы Interline с участком ET"
interline :yes
commission "5%/3.5%"

example 'cdgsvo/ab'
agent    "0 % от опубл. тарифов на рейсы Interline без участка ET"
subagent "0 % от опубл. тарифов на рейсы Interline без участка ET"
interline :absent
commission "0%/0%"

carrier "EY", "ETIHAD AIRWAYS"
########################################

example 'svocdg'
agent   "5% от опубл. тарифов на собств. рейсы EY (В договоре Interline не прописан.)"
subagent "3,5% от опубл. тарифов на собств. рейсы EY"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "5%/3.5%"

carrier "F7", "FLY BABOO (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств.рейсы F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тар. на рейсы Interline c участком F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
interline :yes
commission "1%/0%"

example 'cdgsvo/ab'
agent    "1% от опубл. тар. на рейсы Interline без участка F7"
subagent "0,5% от опубл. тарифа на рейсы F7"
interline :absent
commission "1%/0%"

carrier "FB", "BULGARIA AIR"
########################################

example 'svocdg'
agent    "4% от опубл. тарифов на собств. рейсы FB. (В договоре Interline не прописан.)"
subagent "2,8% от опубл. тарифов на собств. рейсы FB."
commission "4%/2.8%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "4%/2.8%"

carrier "FI", "ICELANDAIR  (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы FI (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы FI"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "FV", "RUSSIA"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent "7% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
subagent "5% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :possible
commission '7%/5%'

example 'svocdg/ab'
agent "1 euro с билета на рейсы Interline без участка FV."
subagent "1 руб. с билета на рейсы Interline без участка FV."
interline :absent
commission "1eur/1"

example 'ledsvo/business svoled/business'
agent "по 31.10.2011 года"
agent "9% при продаже пассажирских перевозок в бизнес-классе на рейсы ФГУП «ГТК «Россия» (FV) на направлениях Санкт-Петербург-Москва и обратно, включая рейсы по соглашению «CODE-Share» (в том числе по тарифам ИАТА)."
subagent "По 31.10.2011г.: 7% от опубл.тарифов Бизнес класса на собственные рейсы (FV) на внутренние перевозки, включая рейсы по соглашению «CODE-Share» (в том числе по тарифам ИАТА)."
important!
classes :business
check { (city_iatas - %W(MOW LED)).empty? }
commission '9%/7%'

carrier "GF", "GULF AIR (Глонасс) (НЕ BSP!!!)"
########################################

agent    "7% от тарифа на международные рейсы GF"
subagent "5% от тарифа на международные рейсы GF"
interline :no
disabled #так есть или нет интерлайн? не bsp?
#notbsp
not_implemented
commission "7%/5%"

agent    "5% от тарифа на рейсы GF между аэропортами Персидского залива"
subagent "3,5% от тарифа на рейсы GF между аэропортами Персидского залива"
disabled #персидский залив, бля.
#geo
not_implemented
commission "5%/3.5%"

carrier "HM", "AIR SEYCHELLES (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифа на собств. рейсы HM (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы HM"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "HR", "HAHN AIR  (Авиарепс)"
########################################

# включено с дополнительной проверкой
agent    "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent    "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent    "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent "5 коп. с билета по опубл. тарифам HR"
interline :absent
commission "1/0.05"

carrier "HU", "HAINAN AIRLINES"
########################################

example 'svopek/f'
example 'svopek/f/ab peksvo/f'
agent "20% перелет с 01.01.11-31.10.11 / class F, P, C  of the flight MOW - CHINA или MOW - CHINA - MOW"
subagent "18% перелет с 01.01.11-31.10.11 / class F, P, C of the flight MOW - CHINA или MOW - CHINA - MOW"
subclasses "FPC"
interline :possible
check { city_iatas.first == 'MOW' && country_iatas.include?('CN') }
commission "20%/18%"

example 'svopek/d'
example 'svopek/d/ab persvo/d'
agent "15% перелет с 01.01.11-31.10.11 / class D, I, J  of the flight MOW - CHINA или MOW - CHINA - MOW"
subagent "13% перелет с 01.01.11-31.10.11 / class D, I, J of the flight MOW - CHINA или MOW - CHINA - MOW"
subclasses "DIJ"
interline :possible
check { city_iatas.first == 'MOW' && country_iatas.include?('CN') }
commission "15%/13%"

example 'svopek/z'
example 'svopek/z/ab peksvo'
agent "9% перелет с 01.01.11-31.10.11 / class Y,B,H,K,L,M,Q,W,S,U,E,O of the flight MOW - CHINA или MOW - CHINA - MOW"
subagent "7% перелет с 01.01.11-31.10.11 / class Y,B,H,K,L,M,Q,W,S,U,E,O of the flight MOW - CHINA или MOW - CHINA - MOW"
subclasses "YBHKLMQWSUEOZ" #Z из другого правила
interline :possible
check { city_iatas.first == 'MOW' && country_iatas.include?('CN') }
commission "9%/7%"

example 'ovbpek'
example 'kjapek pekkja/ab'
agent "9% перелет с 15.05.11-31.10.11с началом перевозки из городов KJA OVB IKT / all class "
subagent "7% перелет с 15.05.11-31.10.11с началом перевозки из городов KJA OVB IKT / all class"
interline :possible
check { %W(KJA OVB IKT).include?(city_iatas.first) }
commission "9%/7%"

example 'peksvo/f'
example 'peksvo/f/ab svopek/d'
agent "3% перелет с 05.05.11 по 31.10.11г./class F, P, C , D , I , J  of the flight CHINA - MOW  или  CHINA - MOW - CHINA"
subagent "1% перелет с 05.05.11 по 31.10.11г./class F, P, C , D , I , J of the flight CHINA - MOW или CHINA - MOW - CHINA"
subclasses "FPCDIJ"
interline :possible
check { city_iatas.include?('MOW') && country_iatas.first == 'CN' }
commission "3%/1%"

example 'peksvo'
example 'peksvo svopek'
agent "3% перелет с 05.05.11 по 31.10.11г./class Y,B,H,K,L,M,Q,X,V,T,S,N,U,  of the flight CHINA - MOW  или  CHINA - MOW - CHINA"
subagent "1% перелет с 05.05.11 по 31.10.11г./class Y,B,H,K,L,M,Q,X,V,T,S,N,U, of the flight CHINA - MOW или CHINA - MOW - CHINA"
classes :economy
subclasses "YBHKLMQXVTSNU"
check { city_iatas.include?('MOW') && country_iatas.first == 'CN' }
commission "3%/1%"

example 'pekweh'
example 'nayweh wehnay'
agent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
check { (country_iatas - ['CN']).blank? && city_iatas.first == 'BJS' }
commission "0%/0%"

example 'cdgnay'
agent "3% начало перелета из третьей страны в Китай на все классы"
subagent "1% начало перелета из третьей страны в Китай на все классы"
check { country_iatas.first != 'CN' }
commission "3%/1%"

#С 01.11.2011г.
agent "9% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent "7% от опубл. тарифов на собств. рейсы HU"
not_implemented

agent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
not_implemented

carrier "HX", "Hong Kong Airlines"
########################################

example 'dmehkg hkgdme/ab'
agent "7% от всех опубликованных тарифов на собственные рейсы HX  и рейсы Interline с участком HX (в/из России). (Без участка HX    интерлайн выписывать запрещено!)"
subagent "5% от опубл. тарифов на совбств. рейсы HX"
check { country_iatas.include?('RU') }
interline :yes
commission "7%/5%"

example 'SVOHKG/BUSINESS/J HKGSVO/BUSINESS/J'
agent "C 15.06.11г. 15% от опубликованных тарифов Бизнес класса (RBD: C,D,J) на собственные рейсы HX (RT или OW)."
subagent "5% от опубл. тарифов на совбств. рейсы HX"
classes :business
subclasses "CDJ"
important!
commission "15%/12%"

example 'svocdg'
agent    "7% от всех опубл. тарифов на собств.рейсы HX (В договоре Interline не прописан.)"
subagent "5% от опубл. тарифов на собств.рейсы HX"
commission "7%/5%"

carrier "HY", "UZBEKISTAN AIRWAYS (Узбекистон Хаво Йуллари) (НЕ BSP!!!)"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств. рейсы HY"
subagent "5% от опубл. тарифов на собств. рейсы HY"
disabled 'не BSP'
commission "5%/5%"

example 'svocdg cdgsvo/ab'
agent    "2% от опубл. тарифов на рейсы Interline"
subagent "2% от опубл. тарифов на рейсы Interline"
interline :yes
disabled 'не BSP'
commission "2%/2%"

carrier "IB", "IBERIA"
########################################

example 'svocdg'
agent    "1 руб. с билета на рейсы IB (В договоре Interline не прописан.)"
subagent "50 коп. с билета на рейсы IB"
commission "1/0.5"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1/0.5"

carrier "IG", "MERIDIANA (РИНГ-АВИА)"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств.рейсы IG (В договоре Interline не прописан.)"
subagent "3,5% от опубл. тарифов на собств.рейсы IG"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "5%/3.5%"

carrier "IY", "YEMENIA YEMEN AIRWAYS"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы IY (В договоре Interline отдельно не прописан.)"
subagent "0,5% от опубл. тарифов на собств. рейсы IY"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "JJ", "TAM Linhas Aereas S.A."
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на собств. рейсы JJ (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы JJ"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "JL", "JAPAN AIRLINES INTERNATIONAL"
########################################

example 'okosvo'
agent    "7% от опубл. тарифа;"
subagent "5% от опубл. тарифа;"
international
commission "7%/5%"

example 'okosvo/first okosvo/business'
agent    "7% от тарифов бизнес и первого классов;"
subagent "5% от тарифов бизнес и первого классов;"
important!
classes :first, :business
commission "7%/5%"

#example 'svohel heloko/ab'
#agent    "7% от тарифов в третьи страны (транзит) и спец.тарифов в Японию ‘Сатогаери’"
#subagent "5% от тарифов в третьи страны (транзит) и спец.тарифов в Японию ‘Сатогаери’"
#interline :yes
#disabled "хитровыебанное правило: САТОГОЕРИ это полет из России в Японию только через хельсинки, париж, франкфурт и только авиакомпаниями LH, FV, SU, AY, S7"
#например, если летим из Москвы, amadeus такое говорит
#1 * MOW-LH/SU/FV/S7-FRA-JL-TYO-JL/NU/JC-OSA                                   
#2 * MOW-AY/SU/FV-HEL-JL-TYO-JL/NU/JC-OSA                                      
#3 * MOW-LH/SU/FV/S7/AF-FRA/PAR-JL-TYO-JL/NU/JC-OSA
#commission "7%/5%"

agent    "5% от спец. тарифа при наличии совместных рейсов JAL, выполняемых другими авиакомпаниями;"
subagent "3,5% от спец. тарифа при наличии совместных рейсов JAL, выполняемых другими авиакомпаниями;"
interline :yes
disabled #спецтариф — это что?
commission "5%/3.5%"

agent    "5% от спец. тарифов в Японию (включая, но не ограничиваясь, ‘Дисковер Джапэн’, молодежные тарифы);"
subagent "3,5% от спец. тарифов в Японию (включая, но не ограничиваясь, ‘Дисковер Джапэн’, молодежные тарифы);"
interline :no
disabled #правило
#unknown
not_implemented
commission "5%/3.5%"

example 'okoaoj'
agent    "5% от тарифов на внутренние рейсы по Японии"
subagent "3,5% от тарифов на внутренние рейсы по Японии"
domestic
commission "5%/3.5%"

example 'svooko okosvo/ab'
agent    "7% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
agent    "Оформление авиабилетов на бланках JAL по Interline  (в случае наличия рейсов других авиакомпаний) возможно  при условии  наличия  соглашения с соответствующей авиакомпанией и хотя бы одного сегмента с международным рейсом JAL."
agent    "Комиссия 7%, в этом случае,  выплачивается только, если авиабилет оформлен по опубликованным тарифам IATA (если при расчете тарифа используются  carrier fares"
agent    "других авиакомпаниях, то комиссия с них не выплачивается)."
subagent "5% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
interline :yes
commission "7%/5%"

carrier "JP", "ADRIA AIRWAYS"
########################################

example 'svocdg'
agent    "1 руб. с билета на рейсы JP (В договоре Interline не прописан.)"
subagent "50 коп. с билета на рейсы JP"
commission "1/0.5"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1/0.5"

carrier "JU", "JAT AIRWAYS"
########################################

example 'svocdg'
agent "С 15.02.2011г. 7% от опубл. тарифов на собств. рейсы JU"
subagent "JU	С 21.02.2011г. 5% от опубл. тарифов на собств. рейсы JU"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent "С 15.02.2011г. 0% от опубл. тарифов на рейсы Interline"
subagent "С 21.02.2011г. 0% от опубл. тарифов на рейсы Interline"
interline :yes
commission "0%/0%"

carrier "KC", "Air Astana"
########################################

example 'tsekgf'
agent    "5% от тарифа по маршрутам внутри Республики Казахстан;"
subagent "3,5% от тарифа по маршрутам внутри Республики Казахстан;"
interline :no
domestic
commission "5%/3.5%"

example 'svoala'
agent    "7% от прямых опубликованных тарифов по международным маршрутам;"
subagent "5% от прямых опубликованных тарифов по международным маршрутам;"
disabled "фильтр прямого тарифа"
commission "7%/5%"

example 'svoala alasvo'
agent    "7% от сквозных опубликованных тарифов по международным маршрутам;"
subagent "5% от сквозных опубликованных тарифов по международным маршрутам;"
disabled "фильтр сквозного тарифа"
commission "7%/5%"

example 'svoala alasvo'
agent    "7% от сквозных опубликованных тарифов, установленных в соответствии со специальным прорейтовым соглашением с другой авиакомпанией, по международным маршрутам;"
subagent "5% от сквозных опубликованных тарифов, установленных в соответствии со специальным прорейтовым соглашением с другой авиакомпанией, по международным маршрутам;"
interline :yes
disabled "фильтр сквозного тарифа"
commission "7%/5%"

example 'tseala alasvo'
agent    "6% от опубликованных тарифов при их комбинации END-ON-END (внутренний тариф + международный тариф) за продажу перевозки по внутреннему и международному маршрутам, оформленным в одном авиабилете;"
subagent "4,2% от опубликованных тарифов при их комбинации END-ON-END (внутренний тариф + международный тариф) за продажу перевозки по внутреннему и международному маршрутам, оформленным в одном авиабилете; "
disabled "комбинация"
commission "6%/4.2%"

example 'svocdg/ab cdgsvo/ab'
agent    "5% от тарифов на рейсы Interline без сегмента КС;"
subagent "3,5% от тарифов на рейсы Interline без сегмента КС;"
interline :absent
commission "5%/3.5%"

example 'svocdg/ab cdgsvo'
agent    "7% от тарифов на рейсы Interline в комбинации с рейсом KC по всему маршруту;"
subagent "5% от тарифов на рейсы Interline в комбинации с рейсом KC по всему маршруту;"
interline :yes
commission "7%/5%"

carrier "KE", "KOREAN AIR"
########################################

#example 'icnsvo'
example 'svoicn icnsvo/ab'
no_commission

example 'svogmp'
agent "С 01.04.2011г. 5% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
subagent "С 01.04.2011г. 3% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
check { country_iatas.first == 'RU'}
commission "5%/3%"

example 'gmpsvo'
agent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
subagent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
check { country_iatas.first != 'RU'}
commission "0%/0%"

carrier "KL", "KLM"
########################################

example 'svocdg'
agent    "1 euro с билета на рейсы KL. Вознаграждение не выплачивается за любые тарифы net. (Билеты Interline могут быть выписаны на бланках KLM только в случае существования действующего интерлайн соглашения, официально опубл. тарифов и только при условии, если КЛМ или авиакомпания Эр Франс участвуют в одном из сегментов перевозки.)"
subagent "5 руб. с билета на рейсы KL."
interline :possible
commission "1eur/5"

# FIXME странное правило интерлайна для AF
example 'svocdg/af svocdg/ab'
not_implemented
commission "1eur/5"

carrier "KM", "AIR MALTA  (Авиарепс)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы KM"
subagent "0,5% от опубл. тарифа на рейсы KM"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на рейсы Interline"
subagent "0,5% от опубл. тарифа на рейсы Interline"
interline :yes
commission "1%/0.5%"

carrier "LA", "LAN Airlines"
########################################

example 'svocdg'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LA"
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
commission "1/0.05"

agent    "1 руб. с билета по опубл. тарифам на рейсы Interline c участком LA. Interline под кодом LA может быть выписан только при условии, что LA выполняет как минимум один рейс. За несоблюдение данного условия будет начислен штраф в размере EUR200."
agent    "Оформление отдельного авиабилета на рейсы других перевозчиков в пределах региона Южная и Центральная Америка на электронном стоке  LA ВОЗМОЖНО при условии, что внешний участок, т.е. межконтинентальный перелет, осуществляется авиакомпанией LAN. При выписке разными бланками внешнего и внутренних перелетов, все сегменты должны фигурировать в одном бронировании."
agent    "Также необходимо проверять наличие MITA и BITA соглашений. В других случаях оформление авиабилетов по интерлайн соглашению на электронном стоке авиакомпании LAN Airlines (045) не разрешено."
agent    "Комиссия при оформлении авиабилетов по Interline на электронном стоке авиакомпании LAN Airlines (045) во всех случаях составляет 1 руб. Авиакомпания вправе начислить штраф (ADM) за нарушение правил оформленная билета, неверную калькуляцию и т.п."
subagent "???"
interline :yes
disabled #сложни правило, валидатор хочет лететь экстернал, в случае продажи не в омерике + нет субагентских комиссий по интерлайну
#newinternal
#geo
#unknown
not_implemented
commission "1/0.05"

carrier "LH", "LUFTHANSA"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
interline :possible
commission "1/0.05"

# FIXME вынести подразделения в основное правило
example 'svocdg/4U'
agent    "1 руб. с билета на рейсы 4U на бланках LH (подразделение)"
subagent "5 коп. с билета на рейсы 4U на бланках LH (подразделение)"
interline :absent
check { marketing_carrier_iatas == ['4U'] }
commission "1/0.05"

example 'svocdg/ab'
no_commission


carrier "LO", "LOT"
########################################

example 'svocdg'
agent    "1 euro с билета по опубл. тарифам на рейсы LO;"
subagent "5 руб. с билета по опубл. тарифам на рейсы LO;"
commission "1eur/5"

example "svocdg cdgsvo/ab"
agent "отсутствует в договоре, но считаем равным обычным тарифам"
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline с участком LO."
interline :yes
commission "1eur/5"

carrier "LX", "SWISS"
########################################

example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX."
agent    "(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
interline :possible
#FIXME с этой странной доплатой выше - что?
commission "1/0.05"

carrier "LY", "EL AL ISRAEL AIRLINES"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов Эконом класса на рейсы LY"
subagent "3,5% от опубл. тарифов Эконом класса на рейсы LY"
classes :economy
commission "5%/3.5%"

example 'svocdg/business cdgsvo/business'
agent    "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
classes :business
commission "9.7%/6.7%"

example 'svocdg cdgsvo/business'
example 'svocdg cdgsvo/ab'
no_commission

carrier "MA", "MALEV"
########################################

agent    "1 руб. с билета от опубл., конфиде.тарифов Эконом и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
subagent "5 коп. с билета от опубл., конфиде.тарифов Экономического и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
commission "1/0.05"

# копия, потому что у меня нет interline :possible для половины маршрута
agent    "1 руб. с билета от опубл., конфиде.тарифов Эконом и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
subagent "5 коп. с билета от опубл., конфиде.тарифов Экономического и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
interline :half
commission "1/0.05"

carrier "MK", "AIR MAURITIUS"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на рейсы MK (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы MK"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "MS", "EGYPT AIR"
########################################

example 'svocai caisvo'
agent    "9% от тарифа на рейсы MS из Москвы"
subagent "7% от тарифа на рейсы MS из Москвы"
check { city_iatas.first == 'MOW'}
commission "9%/6.3%"

example 'caisvo svocai'
agent    "5% от тарифа на рейсы MS из Египта"
subagent "3,5% от тарифа на рейсы MS из Египта"
international
check { country_iatas.first == 'EG'}
commission "5%/3.5%"

example 'cdgcai'
agent    "5% от тарифа для иных международных рейсов MS"
subagent "3,5% от тарифа для иных международных рейсов MS"
international
commission "5%/3.5%"

example 'caihrg'
agent    "0% от тарифа на рейсы MS внутри Египта"
subagent "0% от тарифа на рейсы MS внутри Египта"
domestic
commission "0%/0%"

example 'caisvo svocai/su'
agent    "0% от тарифа на все иные сектора авиабилетов Interline"
subagent "0% от тарифа на все иные сектора авиабилетов Interline"
interline :yes
commission "0%/0%"

carrier "MU", "CHINA EASTERN"
########################################

#конфиде-тарифов нет
example 'svocdg cdgsvo/ab'
agent    "от опубликованных тарифов:"
agent    "1euro на международные рейсы MU; на рейсы MU до Гонконга, Макао; при выписке международного перелета MU и перелета по территории КНР MU на одном бланке; на внутренние рейсы MU по территории КНР; на рейсы MU и рейсы других авиакомпаний на бланке MU или на  рейсы других  авиакомпаний на бланке MU на любые участки."
agent    "Опубл. считаются только классы: “F” – первый класс, “C” – бизнес класс, “Y” – эконом класс"
subagent "от опубликованных тарифов:"
subagent "5 руб. на международные рейсы MU; на рейсы MU до Гонконга, Макао; при выписке международного перелета MU и перелета по территории КНР MU на одном бланке; на внутренние рейсы MU по территории КНР; на рейсы MU и рейсы других авиакомпаний на бланке MU или на  рейсы других  авиакомпаний на бланке MU на любые участки."
subagent "Опубл. считаются только классы: “F” – первый класс, “C” – бизнес класс, “Y” – эконом класс"
interline :possible
commission "1eur/5"

carrier "NN", "VIM-Airlines"
########################################

example 'dmebsl'
example 'bsldme'
example 'dmevda'
example 'vdadme'
example 'DMEBSL/Q BSLDME/W'
example 'DMEVDA/V VDADME/V'
agent    "7% от опубл. тарифов по маршрутам DME-BSL-DME; DME-VDA-DME на собств.рейсы NN"
subagent "5% от опубл. тарифов по маршрутам DME-BSL-DME; DME-VDA-DME на собств.рейсы NN"
routes %W(MOW-BSL-MOW MOW-VDA-MOW MOW-BSL BSL-MOW MOW-VDA VDA-MOW)
commission "7%/5%"

example 'SVXDME/W'
example 'dmesvx'
example 'KRRDME/W'
example 'dmekrr'
example 'SVXDME/W DMESVX/T'
example 'KRRDME/W DMEKRR/W'
agent    "C 29.11.2010г. 7% от опубл. тарифов по маршрутам SVX-DME-SVX; KRR-DME-KRR на собств.рейсы NN"
subagent "5% от опубл.тарифов по маршрутам SVX-DME-SVX; KRR-DME-KRR на собств.рейсы NN"
routes %W(SVX-MOW-SVX KRR-MOW-KRR SVX-MOW MOW-SVX KRR-MOW MOW-KRR)
commission "7%/5%"

example 'DMEBCN/Q BCNDME/Q'
agent    "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
agent    "(В договоре Interline не прописан.)"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
commission "5%/3.5%"

#example 'DMEKRR/W KRRDME'
#disabled 'а так можно?'

carrier "NZ", "AIR NEW ZEALAND (НЕ BSP!!!)"
########################################

agent    "7% от тарифа на международные перелеты на рейсы NZ;"
subagent "5% от тарифа на международные перелеты на рейсы NZ;"
international
disabled 'не BSP'
commission "7%/5%"

agent    "5% от тарифа на внутренние перелеты на рейсы NZ."
subagent "3,5% от тарифа на внутренние перелеты на рейсы NZ."
domestic
disabled 'не BSP'
commission "5%/3.5%"

carrier "OA", "OLYMPIC AIR (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собственные рейсы OA (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы OA"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "OK", "CZECH AIRLINES"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств.рейсы OK;"
subagent "0,5% от опубл. тарифа на рейсы OK;"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на рейсы Interline, если один из сегментов выполнен под кодом OK."
subagent "0,5% от опубл. тарифа на рейсы Interline, если один из сегментов выполнен под кодом OK."
interline :yes
commission "1%/0.5%"

example 'cdgsvo/ab'
no_commission

carrier "OM", "MIAT-Монгольские Авиалинии"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на рейсы OM (В договоре Interline не прописан.)"
subagent "6,3% от опубл. тарифов на собств.рейсы OM"
commission "9%/6.3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "9%/6.3%"

carrier "OS", "AUSTRIAN AIRLINES"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
agent    "(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
interline :possible
commission "1/0.05"

example 'cdgsvo/ab'
no_commission

carrier "OU", "CROATIA AIRLINES  (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы OU"
subagent "0,5% от опубл. тарифа на собств.рейсы OU"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на рейсы Interline с участком OU."
subagent "0,5% от опубл. тарифа на рейсы Interline с участком OU."
interline :yes
commission "1%/0.5%"

example 'cdgsvo/ab'
no_commission

carrier "OV", "ESTONIAN AIR  (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы OV (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы OV"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "PG", "BANGKOK AIRWAYS (Тальавиэйшн)"
########################################

example 'svocdg'
agent    "5% от всех опубл. тарифов на рейсы PG (В договоре Interline не прописан.)"
subagent "3,5% от опубликованных тарифов на рейсы PG"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "5%/3.5%"

carrier "PS", "Ukraine International Airlines (ГЛОНАСС)"
########################################

example 'svocdg'
agent    "9% от опубл. тарифов на собств.рейсы PS"
subagent "7% от опубл. тарифов на собств.рейсы PS"
commission "9%/7%"

example 'cdgsvo svocdg/ab'
agent "С 01.08.11г. 5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent "0р Interline не прописан"
interline :yes
disabled "no subagent"
commission "5%/7%"

example 'cdgsvo/ab'
agent "С 01.08.11г. 0% от опубл. тарифов на рейсы Interline без участка PS"
subagent ""
interline :absent
no_commission

carrier "QF", "QANTAS AIRWAYS\n(не BSP!!!)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на рейсы QF (В договоре Interline не прописан.)"
subagent "4,9% от опубл. тарифов на рейсы QF"
disabled 'не bsp'
commission "7%/4.9%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
disabled 'не bsp'
interline :unconfirmed
commission "7%/4.9%"

carrier "QR", "QATAR AIRWAYS"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств. рейсы QR"
subagent "3,5% от опубл. тарифов на собственные рейсы QR"
commission "5%/3.5%"

example 'svocdg cdgsvo/ab'
agent    "5% от опубл. тарифов на рейсы Interline (только при обязательном пролете первого сектора на рейсах QR)"
subagent "3,5% от опубл. тарифов на рейсы Interline (только при обязательном пролете первого сектора на рейсах QR)"
interline :first
commission "5%/3.5%"

example 'cdgsvo/ab svocdg'
no_commission

carrier "RB", "SYRIAN ARAB AIRLINES"
########################################

example 'svocdg'
agent    "7% от всех опубл. тарифов на рейсы RB (В договоре Interline не прописан.)"
subagent "5% от опубл. тарифов на рейсы RB"
commission "7%/5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "7%/5%"

carrier "S4", "SATA INTERNACIONAL (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на собств.рейсы S4 (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы S4"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "SA", "South African Airways"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на собств. рейсы. SA и рейсы Interline"
subagent "0,5% от опубл. тарифа на собств. рейсы SA и рейсы Interline"
interline :possible
commission "1%/0.5%"

carrier "SK", "SAS"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета на рейсы SAS. (Билеты «Интерлайн» под кодом Авиакомпании могут быть выписаны только в случае существования опубл. тарифов и только при условии, если Авиакомпания выполняет хотя бы один рейс.)"
subagent "50 коп. с билета на рейсы SAS"
interline :possible
commission "1/0.5"

carrier "SN", "BRUSSELS AIRLINES"
########################################

example 'svocdg'
example 'DMEBRU'
example 'BRULBA'
agent    "0,5% от опубл. тарифам на собств. рейсы SN;"
subagent "5 руб. с билета по опубл. тарифам на собств. рейсы SN;"
commission "0.5%/5"

example 'svocdg cdgsvo/ab'
agent    "0,5% от опубл. тарифам в случае применения совмещенного тарифа авиакомпаний;"
subagent "5 руб. с билета по опубл. тарифам в случае применения совмещенного тарифа авиакомпаний;"
interline :yes
commission "0.5%/5"

carrier "SQ", "SINGAPORE AIRLINES (Авиарепс)"
########################################

example 'svosin'
agent    "3% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
subagent "2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
# interline :possible
check { country_iatas.first == 'RU'}
commission "3%/2%"

example 'svohou houmia'
example 'housvo'
agent    "6% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
subagent "4,2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
important!
# interline :possible
check { country_iatas.first == 'RU' && city_iatas.include?('HOU') ||
  city_iatas.first == 'HOU' && country_iatas.last == 'RU' }
commission "6%/4.2%"

example 'miahou housvo'
example 'sinsvo'
example 'housvo svosin'
example 'sinsvo svosin/su'
agent    "3% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
agent    "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
subagent "2% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
subagent "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
interline :possible
commission '3%/2%'

carrier "SW", "AIR NAMIBIA (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы SW (В договоре Interline отдельно не прописан.)"
subagent "5% от опубл. тарифов на собств.рейсы SW"
commission "7%/5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "7%/5%"

carrier "TG", "THAI AIRWAYS"
########################################

example 'svobkk'
agent "С 01.02.2011г. 5% от всех опубл.и конфиденциальных тарифов на международные рейсы TG"
subagent "С 01.02.2011г. 3% от опубл. и конфиде.тарифов на международные рейсы TG"
international
commission "5%/3%"

example 'bkkdmk'
agent "С 01.02.2011г. 0% от всех опубл. тарифов на внутренние рейсы TG"
subagent "С 01.02.2011г. 0% от опубл.тарифов на внутренние рейсы TG"
domestic
commission "0%/0%"

example 'svobkk/su bkkdmk'
agent "С 01.02.2011г. 0% от тарифов на рейсы Interline. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
subagent "С 01.02.2011г. 0% от опубл. тарифа на рейсы Interline с участком TG. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
interline :yes
commission "0%/0%"

carrier "TK", "TURKISH AIRLINES"
########################################

agent    "7% от полного опубл. тарифа IATA на рейсы TK;"
subagent "5% от полного опубл. тарифа IATA на рейсы TK;"
not_implemented
commission "7%/5%"

example 'svoist istsvo'
agent    "7% от тарифа эконом класса на рейсы TK;"
subagent "5% от тарифа экономического класса на рейсы TK;"
classes :economy
commission "7%/5%"

example 'svoist/business istsvo/business'
agent    "12% от тарифа бизнес класса на рейсы TK. (только при вылете из РФ. При вылете из других пунктов 7%);"
subagent "10% от тарифа бизнес класса на рейсы TK. (только при вылете из РФ. При вылете из других пунктов 5%);"
important!
classes :business
check { country_iatas.first == 'RU' }
commission "12%/8.4%"

example 'istsvo/business svoist/business'
agent    "12% от тарифа бизнес класса на рейсы TK. (только при вылете из РФ. При вылете из других пунктов 7%);"
subagent "8,4% от тарифа бизнес класса на рейсы TK. (только при вылете из РФ. При вылете из других пунктов 5%);"
important!
check { country_iatas.first != 'RU' }
classes :business
commission "7%/5%"

example 'istank'
example 'istank/business'
agent    "5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
subagent "3,5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
important!
domestic
commission "5%/3.5%"

agent    "*Если C+Y, то 12% Если С+B(M и т.п.) 7%"
subagent "???"
disabled "комбинации"
commission "12%/0%"

example 'svoist istsvo/ab'
agent    "(Билеты «Интерлайн» под кодом TK могут быть выписаны только в случае существования опубл. тарифов и только при условии, если TK выполняет первый рейс)"
subagent "???"
interline :first
disabled "нет субагентской комиссии"
commission "0%/0%"

example 'svoist istsvo/business'
disabled "не включены комбинации"
no_commission

carrier "TP", "TAP PORTUGAL"
########################################

agent    "1% от опубл. тарифов на собств. рейсы TP и рейсы Interline"
subagent "0,5% от опубл. тарифа на собственные рейсы TP и рейсы Interline"
interline :possible
commission "1%/0.5%"

carrier "UA", "UNITED AIRLINES (ГЛОНАСС)"
########################################

# FIXME использую приоритет чтобы закрыть эти субклассы!
agent "До 31.12.11г. 7% от опубл. тарифов по классам бронирования: M, H, Q, V, W, S, L  на собств. рейсы UA из России в США с  обяз. уч. трансатлантич. рейсов UA965/UA964."
subagent "До 31.12.11г. 5% от опубл. тарифов по классам бронирования: M, H, Q, V, W, S, L на собств. рейсы UA из России в США с обяз. уч. трансатлантич. рейсов UA965/UA964."
#subclasses 'MHQVWSL'
check { (flights.every.full_flight_number & %W(UA965 UA964)).any? }
commission "7%/5%"

agent "До 31.12.11г. 9% от опубл.тарифов по классам бронирования: F, A, J, C, D, Z, Y, B на собств. рейсы UA из России в США с обязат. уч. трансатлантич. рейсов UA965/UA964."
subagent "До 31.12.11г. 7% от опубл. тарифов по классам бронирования: F, A, J, C, D, Z, Y, B на собств. рейсы UA из России в США с обязат. уч. трансатлантич. рейсов UA965/UA964."
important!
subclasses 'FAJCDZYB'
check { (flights.every.full_flight_number & %W(UA965 UA964)).any? }
commission "9%/7%"

agent    "0% - на продажу рейсов UA без участия трансатлант. рейса "
subagent "0% от тарифа на продажу рейсов UA без участия трансатл. рейса."
interline :no
disabled #сложное правило, рейсы без участия трансатлантического рейса
#unknown
#flightnumber
not_implemented
commission "0%/0%"

agent    "1% - от всех остальных опубл. тарифов на собств. рейсы UA"
subagent "5 рублей от всех остальных опубл. тарифов на собственные рейсы UA"
interline :no
not_implemented
commission "1%/5"

carrier "UL", "SRI LANKAN AIRLINES"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на собств. рейсы UL (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы UL"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "UX", "Air Europa"
########################################

example 'svocdg'
agent    "5% от всех опубл. тарифов на рейсы UX (В договоре Interline отдельно не прописан.)"
subagent "3,5% от опубл. тарифов на собств. рейсы UX"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "5%/3.5%"

carrier "VN", "VIETNAM AIRLINES"
########################################

# FIXME станет актуальным с включением конфиденциальных тарифов!
agent    "C 01.04.11г. по 31.12.11г. 9% от конфиде. тарифов на рейсы VN;"
subagent "7% от конфиденциальных тарифов на рейсы VN;"
disabled 'конфиденциальные тарифы (ждем субагентсткого апдейта)'
commission "9%/7%"

example 'svohan hansvo'
agent    "7% от опубл. тарифов на междунар.рейсах VN;"
subagent "5% от опубликованных тарифов на международных рейсах VN;"
international
commission "7%/5%"

example 'hansgn'
agent    "5% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent "3,5% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
commission "5%/3.5%"

example 'svohan hansvo/su'
agent    "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
commission "0%/0%"

carrier "VS", "Virgin Atlantic Airways Limited (ГЛОНАСС)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы VS"
subagent "5% от опубл. тарифов на собств.рейсы VS"
commission "7%/5%"

example 'svolhr/ba lhrcce'
agent    "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :yes
# FIXME надо ли проверять трансатлантику?
check { %W(BD BA SU).include?(marketing_carrier_iatas.first) && marketing_carrier_iatas.second == 'VS' }
commission "7%/5%"

example 'svocdg cdgsvo/ab'
no_commission

carrier "VV", "AEROSVIT"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на рейсы VV;"
subagent "3,5% от опубл. тарифов на рейсы VV;"
commission "5%/3.5%"

example 'svocdg cdgsvo/ab'
agent    "3% от опубл. тарифов на рейсы VV в комбинации с рейсами Interline"
subagent "2% от опубл. тарифов на рейсы VV в комбинации с рейсами Interline"
interline :yes
commission "3%/2%"

example 'cdgsvo/ab'
agent    "1% от тарифа на рейсы Interline без участка VV"
subagent "0,5% от опубл. тарифа на рейсы Interline без участка VV"
interline :absent
commission "1%/0.5%"

carrier "WY", "OMAN AIR"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы WY (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы WY"
disabled
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
disabled
commission "1%/0.5%"

carrier "XW", "SkyExpress Limited"
########################################

example 'svocdg'
agent    "С 11.04.11г.  7 (Семь) % от всех опубликованных тарифов на собственные рейсы авиакомпании;"
subagent "С 11.04.11г. 5% от всех опубл. тарифов на собств. рейсы XW;"
interline :no
commission "7%/5%"

example 'svocdg cdgsvo/gw'
agent     "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) - как с участием, так и без участия собственных рейсов SkyExpress Limited Company (ЗАО “Небесный Экспресс”) (XW/492);"
subagent "С 11.04.11г. 3% от всех опубл. тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) – с/без участия собств. рейсов XW;"
interline :yes
check { (marketing_carrier_iatas - ['XW']).uniq == ['GW']}
commission "5%/3%"

example 'svopee peesvo/xf'
agent "С 11.04.11г. 1 (Один) Рубль РФ от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) - как с участием, так и без участия"
subagent "С 11.04.11г. 5 коп с билета по опубл. тарифам на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) – с/без участия собств. рейсов XW."
interline :yes
check { (marketing_carrier_iatas - ['XW']).uniq == ['XF']}
commission "1/0.05"

carrier "YM", "MONTENEGRO AIRLINES"
########################################

example 'svocdg'
agent    "8% от всех опубл. тарифов на рейсы YM (В договоре Interline не прописан.)"
subagent "6% от всех опубл. тарифов на рейсы YM"
commission "8%/6%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "8%/6%"

carrier "YO", "Heli air Monaco (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1 руб. с билета на все виды тарифов (В договоре Interline не прописан.)"
subagent "50 коп. с билета на рейсы YO"
commission "1/0.5"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1/0.5"

carrier "ZI", "AIGLE AZUR (РИНГ-АВИА)"
########################################

example 'svocdg'
agent    "1 рубль от опубл. тарифов на собств. рейсы ZI (В договоре Interline отдельно не прописан.)"
subagent "5 коп от опубл. тарифа на собств. рейсы ZI"
commission "1/0.05" #первомайский апдейт

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
disabled "разобрать"
commission "1/0"

carrier "J2", "Azerbaijan Hava Yollari"
########################################

example 'svocdg'
agent    "1 рубль за 1 выписанный билет на стоке 771"
subagent "5 коп. с билета по опубл тарифам на собств. рейсы J2"
commission "1/0.05"

carrier "AT", "ROYAL AIR MAROC"
########################################

example 'svocdg'
agent "5% от опубл. тарифов Эконом класса на собств. рейсы АТ"
subagent "3% от опубл. тарифов Эконом класса на собств. рейсы АТ"
classes :economy
commission "5%/3%"

example 'svocdg/business'
agent "7% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
subagent "5% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
classes :business
commission "7%/5%"

example 'svocdg cdgsvo/ab'
no_commission

carrier "NX", "AIR MACAU"
########################################

example 'svocdg'
agent "5 % от всех опубл. тарифов на собственные рейсы NX"
subagent "3% от всех опубл. тарифов на собственные рейсы NX"
commission "5%/3%"

carrier "U6", "ОАО Авиакомпания  УРАЛЬСКИЕ  АВИАЛИНИИ"
########################################

agent "в размере 7 (семь)%,  продажа международных перевозок по опуб.тар и продажа трансферных перевозок по сквозным тарифам и трансферных перевозок по сквозным тарифам, полученным путем end-on-end комбинации опубликованных тарифов перевозчиков;"
subagent ""
disabled
commission "7%/0"

agent "в размере 6 (шести)%, продажа перевозок  по  СНГ и  продажа трансферных перевозок  по сквозным тарифам и трансферных перевозок  по сквозным тарифам, полученным путем end-on-end комбинации опубликованных тарифов перевозчиков"
agent "Примечание: Если один из участков перевозки - дальнее зарубежье (или СНГ), то перевозка считается международной (или СНГ)."
subagent ""
disabled
commission "6%/0"

agent "в размере 6 (шести)%, продажа перевозок  в эконом классе по России  и продажа перевозок  по   продаже трансферных перевозок  по сквозным тарифам и трансферных перевозок  по сквозным тарифам, полученным путем end-on-end комбинации опубликованных тарифов перевозчиков"
subagent "4% от опубл. тарифов Эконом класса на собств. рейсы U6 по России;"
disabled
commission "6%/0"

agent "∙ в размере 9 (девять)%, продажа перевозок  в бизнес класса по России и продажа перевозок  по   продаже трансферных перевозок  по сквозным тарифам и трансферных перевозок  по сквозным тарифам, полученным путем end-on-end комбинации опубликованных тарифов перевозчиков"
subagent "7% от опубл. тарифов Бизнес класса на собств. рейсы U6 по России;"
disabled
commission "9%/0"

example 'svxaer'
example 'svxaer aersvx'
agent    "15 руб. за сегмент по маршрутам:"
agent    "Екатеринбург-Сочи; Сочи-Екатеринбург"
agent    "Екатеринбург-Симферополь;  Симферополь-Екатеринбург;"
agent    "Екатеринбург-Самара;  Самара-Екатеринбург;"
agent    "Екатеринбург-Якутск; Якутск-Екатеринбург;"
agent    "Екатеринбург-Норильск; Норильск-Екатеринбург;"
agent    "Екатеринбург-Чита; Чита-Екатеринбург;"
agent    "Екатеринбург-Анапа; Анапа-Екатеринбург"
agent    "Екатеринбург-Уфа;  Уфа-Екатеринбург."
agent    "Екатеринбург-Казань; Казань-Екатеринбург;"
subagent "5 руб. за сегмент по маршрутам:"
subagent "Екатеринбург-Сочи; Сочи-Екатеринбург"
subagent "Екатеринбург-Симферополь; Симферополь-Екатеринбург;"
subagent "Екатеринбург-Самара; Самара-Екатеринбург;"
subagent "Екатеринбург-Якутск; Якутск-Екатеринбург;"
subagent "Екатеринбург-Норильск; Норильск-Екатеринбург;"
subagent "Екатеринбург-Чита; Чита-Екатеринбург;"
subagent "Екатеринбург-Анапа; Анапа-Екатеринбург"
subagent "Екатеринбург-Уфа; Уфа-Екатеринбург."
subagent "Екатеринбург-Казань; Казань-Екатеринбург;"
important!
# копия для "туда обратно"
routes %W(SVX-AER AER-SVX SVX-SIP SIP-SVX SVX-KUF KUF-SVX SVX-YKS YKS-SVX SVX-NSK NSK-SVX SVX-HTA HTA-SVX SVX-AAQ AAQ-SVX SVX-UFA UFA-SVX SVX-KZN KZN-SVX) +
       %W(SVX-AER-SVX AER-SVX-AER SVX-SIP-SVX SIP-SVX-SIP SVX-KUF-SVX KUF-SVX-KUF SVX-YKS-SVX YKS-SVX-YKS SVX-NSK-SVX NSK-SVX-NSK SVX-HTA-SVX HTA-SVX-HTA SVX-AAQ-SVX AAQ-SVX-AAQ SVX-UFA-SVX UFA-SVX-UFA SVX-KZN-SVX KZN-SVX-KZN)
commission '15/5'

agent "- за каждую багажную квитанцию, при оформлении перевозки сверхнормативного багажа;"
agent "- за каждый оформленный МСО при оформлении возврата или обмена авиабилетов с взиманием штрафных санкций              !!!"
agent "∙ 3 (три)%  от примененных тарифов на сегментах перевозки рейсов интерлайн-партнеров Авиакомпании ( наличие участка Авиакомпании в билете обязательно)  "
subagent ""
disabled
commission "3%/0"

agent "∙ в размере 15 (пятнадцать) рублей за каждый выписанный авиабилет по конфиденциальным IT тарифам"
subagent ""
disabled
commission "15/0"

example 'dmepee/ab'
agent    "1 руб.  от опубл. тарифов на рейсы Interline без участка U6;"
subagent "5 коп. от опубл. тарифов на рейсы Interline без участка U6;"
interline :absent
disabled "субагентских нет"
commission '1/0.05'

agent ""
subagent "все субагентсткие"
subagent "4% от опубл. тарифов Эконом класса на собств. рейсы U6 по России;"
subagent "7% от опубл. тарифов Бизнес класса на собств. рейсы U6 по России;"
subagent "5 (пять) рублей с билета по опубл. тарифам на собств. рейсы U6 по России по маршрутам Группы А:"
subagent "Екатеринбург-Симферополь; Симферополь-Екатеринбург; Симферополь-Екатеринбург-Симферополь;"
subagent "Екатеринбург-Симферополь-Екатеринбург;"
subagent "Екатеринбург-Самара-Екатеринбург; Екатеринбург-Самара; Самара-Екатеринбург; Самара-"
subagent "Екатеринбург-Самара;"
subagent "Екатеринбург-Якутск-Екатеринбург; Екатеринбург-Якутск; Якутск-Екатеринбург; Якутск-Екатеринбург-Якутск"
subagent "Екатеринбург-Норильск-Екатеринбург; Екатеринбург-Норильск; Норильск-Екатеринбург; Норильск- Екатеринбург-Норильск;"
subagent "Екатеринбург-Чита-Екатеринбург; Екатеринбург-Чита; Чита-Екатеринбург; Чита-Екатеринбург-Чита;"
subagent "Екатеринбург-Анапа-Екатеринбург; Екатеринбург-Анапа; Анапа-Екатеринбург; Анапа-Екатеринбург- Анапа;"
subagent "Екатеринбург-Уфа-Екатеринбург; Екатеринбург-Уфа; Уфа-Екатеринбург; Уфа-Екатеринбург-Уфа;"
subagent "Екатеринбург-Казань-Екатеринбург; Екатеринбург-Казань; Казань-Екатеринбург; Казань- Екатеринбург-Казань."
subagent "4% от опубл. тарифов на собств. рейсы U6 по СНГ;"
subagent "5% от опубл. тарифов на собств. международные рейсы U6;"
subagent "4% от опубл. сквозных тарифов на собств. трансферные перевозки U6;"
subagent "4% от опубл. сквозных тарифов на собств. трансферные перевозки U6 полученные путем end-on-end комбинации. Кроме маршрутов Группы А (см. комиссию Группы А);"
subagent "1% от опубл. тарифов на рейсы Interline с участком U6;"
subagent "5 коп. с билета по опубл. тарифам на рейсы Interline без участка U6."
disabled "пиздец"
commission "0/0"

carrier "GW", "AIR LINES OF KUBAN"
########################################

example 'svocdg'
agent "5% от опубл. тарифов на собств. рейсы авиакомпании."
subagent "3% от всех опубл. тарифов на собств. рейсы GW"
commission "5%/3%"

example 'svocdg cdgsvo/ab'
agent "3% от опубл. тарифов на рейсы Interline c обязательным участием GW. Выписка на рейсы Interline без участка GW запрещена."
subagent "3% от всех опубл. тарифов на собств. рейсы GW"
interline :yes
commission "5%/3%"

carrier "CQ", "Czech Connect Airlines"
########################################

example 'svocdg'
agent "6% от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "4% от всех опубл. тарифов на собств. рейсы CQ"
commission "6%/4%" #первомайский апдейт

example 'svocdg cdgsvo/ab'
agent "6% от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "4% от всех опубл. тарифов на собств. рейсы CQ"
interline :unconfirmed
commission "6%/4%" #первомайский апдейт

carrier "W5", "Airline «MAHAN AIR» (АВИАРЕПС)"
########################################

example 'svocdg'
agent "5 % от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "3% от всех опубл.тарифов на собств. рейсы W5"
commission "5%/3%"

example 'svocdg cdgsvo/ab'
agent "5 % от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "3% от всех опубл.тарифов на собств. рейсы W5"
interline :unconfirmed
commission "5%/3%"

carrier "IZ", "Arkia"
########################################

example 'svocdg'
agent "7% от всех опубл. тарифов; (Interline отдельно не прописан)"
subagent "5% от всех опубл.тарифов на собств. рейсы IZ"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent "7% от всех опубл. тарифов; (Interline отдельно не прописан)"
subagent "5% от всех опубл.тарифов на собств. рейсы IZ"
interline :unconfirmed
commission "7%/5%"

carrier "5L", "AEROSUR (РИНГ АВИА)"
########################################

example 'svocdg'
agent "1% от опубл. тарифов на собств. рейсы 5L"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы 5L"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent "1% от опубл. тарифов на собств. рейсы 5L"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы 5L"
interline :unconfirmed
commission "1%/0.5%"

carrier "FJ", "AIR PACIFIC LIMITED (РИНГ АВИА)"
########################################

example 'TVUNAN/L NANVLI/Q' #между фиджи и фиджи
example 'suvakl aklsuv/ab'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на короткие расстояния,"
agent "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
subagent "3% от всех опубл.тарифов на собств. рейсы FJ для перевозки на короткие расстояния,"
subagent "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
check { (country_iatas - %W(FJ AU NZ KI MH FM NR PG WS SB TO TV VU CK AS PF GU NC NU NF MP PW)).blank? && country_iatas.include?('FJ') }
interline :possible
commission "5%/3%"

example 'suvcdg'
example 'suvcdg cdgsuv/ab'
agent "7% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на дальние расстояния,"
agent "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
subagent "5% от всех опубл.тарифов на собств. рейсы FJ для перевозки на дальние расстояния,"
subagent "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
check { country_iatas.include?('FJ') }
interline :possible
commission "7%/5%"

carrier "RC", "ATLANTIC AIRWAYS (РИНГ АВИА)"
########################################

example 'svocdg'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании. (Interline отдельно не прописан)"
subagent "3% от всех опубл. тарифов на собств. рейсы RC"
commission "5%/3%"

example 'svocdg cdgsvo/ab'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании. (Interline отдельно не прописан)"
subagent "3% от всех опубл. тарифов на собств. рейсы RC"
interline :unconfirmed
commission "5%/3%"

carrier "A3", "AEGEAN AIRLINES S.A"
########################################

example 'svocgd cgdsvo/ab'
agent "1% от всех опубл. и конфиде. тарифов на междунар. и внутр. рейсы A3. Билеты по Interline могут быть выписаны только при условии присутствия сегментов A3 и если на долю А3 приходится более 50% перевозки."
subagent "0,5% от опубл. тарифов и конфиде. тарифов на междунар. и внутр. рейсы A3. Билеты по Interline могут быть выписаны только при условии присутствия сегментов A3"
interline :half
commission "1%/0.5%"

carrier "BJ", "NOUVELAIR (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

agent "6% от всех опубл. тарифов на рейсы BJ"
subagent "4% от всех опубликованных тарифов на рейсы BJ"
commission "6%/4%"

carrier "MD", "AIR MADAGASCAR (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

example 'svocdg'
agent "1 (Один) % от всех опубл. тарифов на собств. рейсы авиакомпании MD"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы MD"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent "1 (Один) % от всех опубл. тарифов на собств. рейсы авиакомпании MD"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы MD"
interline :possible
commission "1%/0.5%"

carrier "TN", "AIR TAHITI NUI (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

example 'svocdg'
agent "1 (Один) рубль от всех опубл. тарифов на собств.рейсы авиакомпании TN"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы TN"
commission "1/0.05"

example 'svocdg cdgsvo/ab'
agent "1 (Один) рубль от всех опубл. тарифов на собств.рейсы авиакомпании TN"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы TN"
interline :possible
commission "1/0.05"

carrier "9U", "Air Moldova"
########################################

example 'dmekiv'
agent "5 (пять) % от всех опубликованных тарифов."
subagent "3% от опубл. тарифов на рейсы 9U"
commission "5%/3%"

carrier "A9", "GEORGIAN AIRWAYS"
########################################

example 'tbsdme'
agent "8 (восемь) % от опубл. тарифа на собств. рейсы авиакомпании А9;"
subagent "6 % от опубл. тарифа на собств. рейсы А9;"
commission "8%/6%"

example 'tbsdme dmetbs/ab'
agent "7 (семь)  % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании  А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение;"
subagent "5 % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение"
interline :yes
commission "7%/5%"

example 'dmetbs/ab'
agent "5 (пять)   % от опубл. тарифа на рейсы Interline без участка А9."
subagent "3 % от опубл. тарифа на рейсы Interline без участка А9."
interline :absent
commission "5%/3%"

carrier "5H", "Five Fourty Aviation Limited"
########################################

example "svocdg"
agent "5 (пять) % от опубл. тарифов на собств. рейсы 5H"
subagent "3% от опубл. тарифов на собств. рейсы 5H"
commission "5%/3%"
end
