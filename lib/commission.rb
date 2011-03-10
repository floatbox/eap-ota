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
subagent "4,5 (четыре с половиной) % от тарифов Эконом класса (в т.ч. при комбинации Эконом и Бизнес классов),   при переоформлении с доплатой по тарифам Эконом класса (в т.ч. при комбинации Эконом и Бизнес классов);"
commission "7%/4.5%"

example "svocdg/business"
important!
agent "- за продажу в Бизнес классе  9 % от тарифа;"
subagent "4,5 (четыре с половиной) % от тарифов Бизнес класса, при переоформлении с доплатой по тарифам Бизнес класса;"
classes :business
commission "9%/4.5%"


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
subagent "1 (один) % от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U."
subclasses "LVXTNIGWU"
commission "3%/1%"

# копии субагентских правил для этих самых 12%

example 'DMEMIA/FIRST/F MIADME/FIRST/F'
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "9 (девять) % от тарифа на рейсы Перевозчика по всем тарифам классов F, J, C, D."
subclasses "FJCD"
important!
check { (city_iatas & %W(NYC MIA BJS)).present? && %W(RU UA KZ UZ).include?(country_iatas.first) }
commission "12%/9%"

example 'DMEJFK/Y JFKDME/Y'
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "5  (пять) % от тарифа на рейсы Перевозчика по всем тарифам классов Y, H, M, Q, B, K, O, R, E."
subclasses "YHMQBKORE"
important!
check { (city_iatas & %W(NYC MIA BJS)).present? && %W(RU UA KZ UZ).include?(country_iatas.first) }
commission "12%/5%"

example 'DMEJFK/I JFKDME/I'
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "1 (один) % от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U."
subclasses "LVXTNIGWU"
important!
check { (city_iatas & %W(NYC MIA BJS)).present? && %W(RU UA KZ UZ).include?(country_iatas.first) }
commission "12%/1%"

example 'DOKDME DMELHR/BD LHREWR/CO'
example 'DMEJFK/I EWRGRU/CO/B GRUEWR/CO/B JFKDME/I'
example 'svocdg cdgmad/ab'
agent "4% МВЛ. ВВЛ Interline с участком UN"
agent "от применяемых опубликованных тарифов премиального экономического, туристического экономического и бизнес классов (one way, round trip; open jaw) за все виды продаж на рейсы UN, включая Interline продажи премиального экономического, туристического экономического и бизнес классов с участком авиакомпании «ТРАНСАЭРО»; запрещена продажа по Interline без участка авиакомпании «ТРАНСАЭРО»."
subagent "2 (два) % от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без участка UN."
interline :yes
commission "4%/2%"

example 'DMELHR/X LHRMUC/BD'
example 'svocdg cdgmad/lh'
agent "5% Дополнительное вознаграждение на продажу Interline от применяемых опубликованных тарифов первого, бизнес, премиального экономического и туристического экономического классов на рейсы авиакомпаний Lufthansa (LH), Austrian Airlines (OS), Swiss International Airlines (LX), British Midland Airways (BD) от Москвы и/или через Москву с участком перевозки на рейсы ТРАНСАЭРО. Дополнительное вознаграждение не выплачивается в случае остальных Interline продаж, а также с сумм произведенных возвратов."
agent "(Т.е. комиссия по этим Interline будет 9%)"
subagent "2 (два) % от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без участка UN."
important!
interline :yes
check { city_iatas.include?('MOW') && (other_marketing_carrier_iatas - %W(LH OS LX BD)).empty? }
commission "9%/2%"

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
agent    "7% от всех опубл. тарифов на рейсы 6H (В договоре Interline отдельно не прописан.)"
subagent "5% от опубл. тарифов на собств. рейсы 6H"
commission "7%/5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "7%/5%"

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
agent    "7% от всех опубл. тарифов на собств. рейсы 7D;"
subagent "5% от всех опубл. тарифов на собств. рейсы 7D;"
commission "7%/5%"

example 'cdgsvo svocdg/ab'
agent    "5% от всех опубл. тарифов на рейсы Interline с участием собств. рейсов 7D;"
subagent "3,5% от всех опубл. тарифов на рейсы Interline с участием собств. рейсов 7D;"
interline :yes
commission "5%/3.5%"

agent    "5% от всех опубл. тарифов на рейсы Interline без участия собств. рейсов 7D;"
subagent "3,5% от всех опубл. тарифов на рейсы Interline без участия собств. рейсов 7D;"
interline :absent
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

example 'svocdg/s7'
no_commission

# example 'svocdg/HG'
# для авиакомпании HG можно interline :absent

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

example 'SVOCDG/AF/K CDGMEX/Q MEXCDG/Q CDGSVO/SU/W'
agent    "9% от всех опубл. тарифов на рейсы AM;"
agent    "новые тарифы экономического класса в Мексику через Европу:"
agent    "• Q, K, S, M"
agent    "• До Парижа/Мадрида – SU, AF, UX"
agent    "• 9 % комиссии при условии одного трансатлантического рейса в бронировании"
agent    "вместе с SU, AF, UX и на собственные рейсы авиакомпании"
subagent "6,3% от опубл. тарифов на рейсы AM"
interline :possible
check { country_iatas.first == 'RU' && city_iatas.include?('MEX') }
commission "9%/6.3%"

example 'PRGCDG CDGBCN'
no_commission

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

agent ""
subagent "На период по 31 марта 2011 года: 5 руб. с билета по эксклюзивным Net тарифам (Private / Nego) из Москвы и С.-Петербурга по отдельным направлениям: LON / ATL / BWI / BOS / CHI / DFW / DEN / HOU / LAX / LAS / MIA/NYC/ORL/ PHL / PHX / SFO / SEA / TPA / WAS / YYC / YMQ / YTO / YVR / BGI / KIN / MBJ / NAS / ANU/ BDA / GCM / GND / POS / PLS / PUJ / SKB / SLU / TAB / CUN / MEX / RIO / SAO / BUE/ HKG / TYO / ABV / CPT / JNB / LAD / LOS / NBO. Правила тарифов опубликованы в GDS. Субагент бронирует и выпускает авиабилеты как IT. Вознаграждение удерживается Субагентом самостоятельно. Размер вознаграждения не может превышать 9% от Нетто тарифа для премиальных классов и 7% для эконом класса. Сбор Агента 2% от тарифа."
disabled "private тарифы"
no_commission

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

example 'svopek peksvo'
agent    "1 евро за билет, выписанный c началом  перевозки от пунктов РФ;"
subagent "5 руб. с билета, от опубл.тарифов на рейсы CA с началом перевозки от пунктов РФ;"
check { country_iatas.first == 'RU' }
commission "1eur/5"

agent    "???"
subagent "0% на все остальные тарифы."
disabled #правило
not_implemented
commission "1eur/0"


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
commission "1%/0.5%"

carrier "CX", "CATHAY PACIFIC (Тальавиэйшн)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы CX и рейсы Interline c участком СX. Можно выписывать на бланках CX других авиаперевозчиков (при условии действующего интерлайна), если: - хотя бы один перелет совершается авиакомпанией CX,"
agent    "- перелет на другом перевозчике является связующим билетом к основному перелету на авиакомпании CX."
agent    "1 руб. от туроператорских тарифов. (Тарифы можно использовать строго при наличии ваучера у пассажира)."
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
commission "7%/5%"

example 'svocdg cdgsvo/ab'
subagent "???" # субагентская комиссия при интерлайне?
interline :yes
not_implemented
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

example 'svocdg'
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

example 'svocdg'
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

example 'svocdg cdgsvo/ab'
example 'cdgsvo'
example 'svomia'
#example 'jfkbwi' временно выключен
agent    "1% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL на трансатлантический перелет при перевозке, начинающейся в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа других авиакомпаний в комбинации с опубл. тарифом DL на трансатлант.перелет при перевозке, нач.в Европе, Азии или Африке;"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :possible
check { %W(europe asia africa).include?( Country.find_by_alpha2(country_iatas.first).continent ) }
commission "1%/0.5%"

example 'cdgsvo/ab'
agent    "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
disabled
commission "1%/0.5%"

example 'EWRDTW DTWYYZ' # ньюйорк - детройт - торонто
agent    "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :possible
disabled
commission "0%/0%"

agent "с 01.10.10г. по 31.03.2011 г. "
agent "к стандартной комиссии БСП 1%  добавляет 7% по направлениям Russian Federation: WORLD "
agent "по всем классам, кроме Т"
agent "-Дополнительная комиссия выплачивается только с началом перевозки из РОССИИ."
agent "-Дополнительная комиссия взимается в дополнение к стандартной комиссии  ИАТА 1% в пункте продаж. "
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
subagent ""
not_implemented
commission "0%/0%"


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
agent    "5% от опубл. тарифов на собств. рейсы EY (В договоре Interline не прописан.)"
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
agent "по 31.03.2011 года"
agent "9% при продаже пассажирских перевозок в бизнес-классе на рейсы ФГУП «ГТК «Россия» (FV) на направлениях Санкт-Петербург-Москва и обратно, включая рейсы по соглашению «CODE-Share» (в том числе по тарифам ИАТА)."
subagent "5% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
important!
classes :business
check { (city_iatas - %W(MOW LED)).empty? }
commission '9%/5%'

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

agent    "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent    "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent    "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent "5 коп. с билета по опубл. тарифам HR"
disabled #это еще что за хрень, придется лазить на сайт что ли
#newinterline
not_implemented
commission "1/0.05"

carrier "HU", "HAINAN AIRLINES"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent "6,3% от опубл. тарифов на собств. рейсы HU"
not_implemented
commission "9%/6.3%"

agent "С 01.01.2011г. дополнительная CLASS COMMISSIOM:"
agent "20% на С CLASS "
agent "15% на D CLASS "
agent "15% на I CLASS "
agent "15% на J CLASS "
agent "7% на Y/B/H/K/L/M/Q/X/V/T/W/S/N/U/E/O"
agent "Rules and conditions:"
agent "1.  Point of sales in Russia only;"
agent "2.  The date of valid flight — 01 January 2011 - 31 March 2011;"
agent "3.  Flight direction is PEK=LED=PEK only;"
agent "4.  The commission of infant and child is the same with adult;"
agent "5.  The commission only for individual passenger, not for group."
subagent "С 01.02.2011г по 31.03.2011г."
subagent "дополнительная комиссия: 15% на С CLASS"
subagent "10% на D CLASS"
subagent "10% на I CLASS"
subagent "10% на J CLASS"
subagent "5% на Y/B/H/K/L/M/Q/X/V/T/W/S/N/U/E/O"
subagent "Rules and conditions:"
subagent "1. Point of sales in Russia only;"
subagent "2. The date of valid flight — 01 January 2011 - 31 March 2011;"
subagent "3. Flight direction is PEK=LED=PEK only;"
subagent "4. The commission of infant and child is the same with adult;"
subagent "5. The commission only for individual passenger, not for group"
not_implemented
no_commission

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
disabled
interline :unconfirmed
commission "9%/6.3%" #wtf checkout

agent "На период до 31.03.2011г. на собств.рейсы HU по опубл. тарифам:"
agent "В России выписать билет, на первый участок из России (например: svo--pek--svo):"
agent "20% на классы F, P, C"
agent "20% на классы F, P, C"
agent "9% на классы Y/B/H/K/L/M/Q/X/V/T/W/S/N/U/E/O"
agent "В России выписать билет, на первый участок из Китая (например: pek--svo—pek):"
agent "20% на классы F, P, C"
agent "15% на классы D, I, J"
agent "7% на классы Y/B/H/K/L/M/Q/X/V/T/W/S/N/U/E/O"
agent "Отдельные перелеты с вылетами из Пекина по Китаю на собственные рейсы HU по опубликованным тарифам 0%"
agent "С 01.04.2011г."
agent "9% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
agent "Отдельные перелеты с вылетами из Пекина по Китаю на собственные рейсы HU по опубликованным тарифам 0%"
subagent "На период до 31.03.2011г. на собств.рейсы HU по опубл. тарифам:"
subagent "В России выписать билет, на первый участок из России (например: svo--pek--svo):"
subagent "15% на классы F, P, C"
subagent "10% на классы D, I, J"
subagent "6,3% на классы Y/B/H/K/L/M/Q/X/V/T/W/S/N/U/E/O"
subagent "В России выписать билет, на первый участок из Китая (например: pek--svo—pek):"
subagent "15% на классы F, P, C"
subagent "10% на классы D, I, J"
subagent "5% на классы Y/B/H/K/L/M/Q/X/V/T/W/S/N/U/E/O"
subagent "Отдельные перелеты с вылетами из Пекина по Китаю на собственные рейсы HU по опубликованным тарифам 0%"
subagent "С 01.04.2011г. 6,3% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent "Отдельные перелеты с вылетами из Пекина по Китаю на собственные рейсы HU по опубликованным тарифам 0%"

carrier "HX", "Hong Kong Airlines"
########################################

example 'svocdg'
agent    "7% от всех опубл. тарифов на собств.рейсы HX (В договоре Interline не прописан.)"
subagent "5% от опубл. тарифов на собств.рейсы HX"
commission "7%/5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
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

example 'svocdg'
agent    "7% от опубл. тарифа;"
subagent "5% от опубл. тарифа;"
interline :no
not_implemented
commission "7%/5%"

example 'svocdg/first cdgsvo/business'
agent    "7% от тарифов бизнес и первого классов;"
subagent "5% от тарифов бизнес и первого классов;"
important!
interline :no
classes :first, :business
not_implemented
commission "7%/5%"

agent    "7% от тарифов в третьи страны (транзит) и спец.тарифов в Японию ‘Сатогаери’"
subagent "5% от тарифов в третьи страны (транзит) и спец.тарифов в Японию ‘Сатогаери’"
interline :no
disabled #правило! сатогаери!!
#geo
#newinterline
not_implemented
commission "7%/5%"

agent    "5% от спец. тарифа при наличии совместных рейсов JAL, выполняемых другими авиакомпаниями;"
subagent "3,5% от спец. тарифа при наличии совместных рейсов JAL, выполняемых другими авиакомпаниями;"
interline :yes
disabled #странное выражение — совсместный рейс. уточнить
#unknown
not_implemented
commission "5%/3.5%"

agent    "5% от спец. тарифов в Японию (включая, но не ограничиваясь, ‘Дисковер Джапэн’, молодежные тарифы);"
subagent "3,5% от спец. тарифов в Японию (включая, но не ограничиваясь, ‘Дисковер Джапэн’, молодежные тарифы);"
interline :no
disabled #правило
#unknown
not_implemented
commission "5%/3.5%"

agent    "5% от тарифов на внутренние рейсы по Японии"
subagent "3,5% от тарифов на внутренние рейсы по Японии"
interline :no
disabled #внутренние рейсы, может интернал какой-то ввести?
#geo
not_implemented
commission "5%/3.5%"

agent    "7% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
agent    "Оформление авиабилетов на бланках JAL по Interline  (в случае наличия рейсов других авиакомпаний) возможно  при условии  наличия  соглашения с соответствующей авиакомпанией и хотя бы одного сегмента с международным рейсом JAL."
agent    "Комиссия 7%, в этом случае,  выплачивается только, если авиабилет оформлен по опубликованным тарифам IATA (если при расчете тарифа используются  carrier fares"
agent    "других авиакомпаниях, то комиссия с них не выплачивается)."
subagent "5% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
interline :yes
not_implemented
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

agent    "5% от тарифа по маршрутам внутри Республики Казахстан;"
subagent "3,5% от тарифа по маршрутам внутри Республики Казахстан;"
interline :no
#внутри казахстана, правило нада
#geo
not_implemented
commission "5%/3.5%"

agent    "7% от прямых опубликованных тарифов по международным маршрутам;"
subagent "5% от прямых опубликованных тарифов по международным маршрутам;"
interline :no
not_implemented
commission "7%/5%"

agent    "7% от сквозных опубликованных тарифов по международным маршрутам;"
subagent "5% от сквозных опубликованных тарифов по международным маршрутам;"
interline :no
disabled #сквозных? wtf? поговорить с Таней
#geo
#unknown
not_implemented
commission "7%/5%"

agent    "7% от сквозных опубликованных тарифов, установленных в соответствии со специальным прорейтовым соглашением с другой авиакомпанией, по международным маршрутам;"
subagent "5% от сквозных опубликованных тарифов, установленных в соответствии со специальным прорейтовым соглашением с другой авиакомпанией, по международным маршрутам;"
interline :no
disabled #боюсь, таки есть свой особенный интерлайн
#newinterline
not_implemented
commission "7%/5%"

agent    "6% от опубликованных тарифов при их комбинации END-ON-END (внутренний тариф + международный тариф) за продажу перевозки по внутреннему и международному маршрутам, оформленным в одном авиабилете;"
subagent "4,2% от опубликованных тарифов при их комбинации END-ON-END (внутренний тариф + международный тариф) за продажу перевозки по внутреннему и международному маршрутам, оформленным в одном авиабилете; "
interline :no
disabled #правило
#combinations
#geo
not_implemented
commission "6%/4.2%"

example 'svocdg/ab cdgsvo/ab'
agent    "5% от тарифов на рейсы Interline без сегмента КС;"
subagent "3,5% от тарифов на рейсы Interline без сегмента КС;"
interline :absent
commission "5%/3.5%"

agent    "7% от тарифов на рейсы Interline в комбинации с рейсом KC по всему маршруту;"
agent    "• на период с 01.08.2010 по 30.11.2010г. на собственные рейсы по маршрутам:"
agent    "• Москва – Алматы - Москва; • Москва - Астана – Москва"
agent    "И комбинации с этими городами."
agent    "Повышенная комиссия Агента 9 (девять) % от тарифа"
subagent "5% от тарифов на рейсы Interline в комбинации с рейсом KC по всему маршруту;"
interline :yes
disabled #видать закончился срок
#diedperiod
not_implemented
commission "7%/5%"

carrier "KE", "KOREAN AIR"
########################################

example 'svoicn'
example 'svoicn icnsvo'
agent    "По 31.03.2011г. 9% от опубл. тарифов на собств. рейсы KE только с вылетом из России."
subagent "По 31.03.2011г. 6,3% от опубл. тарифов на собств. рейсы KE только с вылетом из России."
check { country_iatas.first == 'RU' }
commission "9%/6.3%"

example 'icnsvo'
example 'svoicn icnsvo/ab'
no_commission

agent "С 01.04.2011г. 5% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
subagent "С 01.04.2011г. 3% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
disabled
commission "5%/3%"

agent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
subagent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
disabled
commission "0%/0%"

carrier "KL", "KLM"
########################################

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

example 'svocdg/ab'
#FIXME с этой странной доплатой выше - что?
not_implemented
no_commission


carrier "LO", "LOT"
########################################

example 'svocdg'
agent    "1 euro с билета по опубл. тарифам на рейсы LO;"
subagent "5 руб. с билета по опубл. тарифам на рейсы LO;"
commission "1eur/5"

agent ""
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline с участком LO."
interline :yes
disabled #нет агентской ставки в случае интерлайна
#geo
not_implemented
commission "nil/5"

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

agent    "с 01.01.2011 года по 31.03.2011"
agent    "7% с продаж опубл. структуры тарифов МАЛЕВ в Бизнес и Эконом. классах с вылетами из Москвы по всем направлениям МАЛЕВ. Вышеизложенная комиссия действует только на продажи рейсов МАЛЕВ (рейсы совместного выполнения исключаются)."
subagent "На период до 31.03.2011г. 5% от опубл. тарифов МАЛЕВ Бизнес и Эконом класса с вылетами из Москвы по всем направлениям МАЛЕВ на собств. рейсы MA (совместные рейсы исключаются)."
important!
check {city_iatas.first == 'MOW' }
commission '7%/5%'

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
subagent "6,3% от тарифа на рейсы MS из Москвы"
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

example 'svocdg cdgsvo/j'
agent    "0% от тарифа по конфид. тарифам;"
subagent "0% от тарифа по конфид. тарифам;"
disabled 'конфиденциальные тарифы'
commission "0%/0%"

example 'svocdg cdgsvo/c'
example 'svocdg cdgsvo/ab'
agent    "от опубликованных тарифов:"
agent    "1euro на международные рейсы MU; на рейсы MU до Гонконга, Макао; при выписке международного перелета MU и перелета по территории КНР MU на одном бланке; на внутренние рейсы MU по территории КНР; на рейсы MU и рейсы других авиакомпаний на бланке MU или на  рейсы других  авиакомпаний на бланке MU на любые участки."
agent    "Опубл. считаются только классы: “F” – первый класс, “C” – бизнес класс, “Y” – эконом класс"
subagent "от опубликованных тарифов:"
subagent "5 руб. на международные рейсы MU; на рейсы MU до Гонконга, Макао; при выписке международного перелета MU и перелета по территории КНР MU на одном бланке; на внутренние рейсы MU по территории КНР; на рейсы MU и рейсы других авиакомпаний на бланке MU или на  рейсы других  авиакомпаний на бланке MU на любые участки."
subagent "Опубл. считаются только классы: “F” – первый класс, “C” – бизнес класс, “Y” – эконом класс"
subclasses 'FCY'
interline :possible
commission "1eur/5"

carrier "NN", "VIM-Airlines"
########################################

example 'DMEBSL/Q BSLDME/W'
example 'DMEVDA/V VDADME/V'
agent    "7% от опубл. тарифов по маршрутам DME-BSL-DME; DME-VDA-DME на собств.рейсы NN"
subagent "5% от опубл. тарифов по маршрутам DME-BSL-DME; DME-VDA-DME на собств.рейсы NN"
disabled
commission "7%/5%"

example 'SVXDME/W DMESVX/T'
example 'KRRDME/W DMEKRR/W'
agent    "C 29.11.2010г. 7% от опубл. тарифов по маршрутам SVX-DME-SVX; KRR-DME-KRR на собств.рейсы NN"
subagent "5% от опубл.тарифов по маршрутам SVX-DME-SVX; KRR-DME-KRR на собств.рейсы NN"
disabled
commission "7%/5%"

example 'DMEBCN/Q BCNDME/Q'
agent    "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
agent    "(В договоре Interline не прописан.)"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
disabled
commission "5%/3.5%"

example 'DMEKRR/W KRRDME'
disabled 'а так можно?'

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
agent    "9% от опубл. тарифов на собств.рейсы PS (В договоре Interline отдельно не прописан.)"
subagent "6,3% от опубл. тарифов на собств.рейсы PS"
commission "9%/6.3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "9%/6.3%"

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
  city_iatas.first == 'HOU' && flights.last.arrival.city.country.iata == 'RU' }
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
subagent "8,4% от тарифа бизнес класса на рейсы TK. (только при вылете из РФ. При вылете из других пунктов 5%);"
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
agent "До 31.03.11г. 7% от опубл. тарифов по классам бронирования: M, H, Q, V, W, S, L  на собств. рейсы UA из России в США с  обяз. уч. трансатлантич. рейсов UA965/UA964."
subagent "До 31.03.2011г. 3,5% от опубл. тарифов эконом. класса за исключением подклассов Y, B на все рейсы UA из Москвы в США, Канаду и Латинскую Америку с обяз. уч. трансатлантич. рейса UA965/UA964."
#subclasses 'MHQVWSL'
check { (flights.every.full_flight_number & %W(UA965 UA964)).any? }
commission "7%/3.5%"

agent "До 31.03.11г. 9% от опубл.тарифов по классам бронирования: F, A, J, C, D, Z, Y, B на собств. рейсы UA из России в США с обязат. уч. трансатлантич. рейсов UA965/UA964."
subagent "До 31.03.2011г. 4,5% от опубл. тарифов в следующих подклассах бронирования: F/A/J/C/D/Z/Y/B на все рейсы UA из Москвы в США, Канаду и Латинскую Америку с обязат. уч. трансатлантич. рейса UA965/UA964."
important!
subclasses 'FAJCDZYB'
check { (flights.every.full_flight_number & %W(UA965 UA964)).any? }
commission "9%/4.5%"

agent    "0% - на продажу рейсов UA без участия трансатлант. рейса авиакомпании UA965/UA964."
subagent "0% от тарифа на продажу рейсов UA без участия трансатл. рейса UA965/UA964."
interline :no
disabled #сложное правило, рейсы без участия трансатлантического рейса определенной авиакомпании. Хрень %)
#unknown
#flightnumber
not_implemented
commission "0%/0%"

agent    "1% - от всех остальных опубл. тарифов на собств. рейсы UA"
subagent "0,5% от всех остальных опубл. тарифов на собственные рейсы UA"
interline :no
not_implemented
commission "1%/0.5%"

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
agent    "7% от конфиденциальных тарифов на рейсы VN;"
subagent "5% от конфиденциальных тарифов на рейсы VN;"
disabled 'конфиденциальные тарифы'
commission "7%/5%"

example 'svohan hansvo'
agent    "7% от опубликованных тарифов на международных рейсах VN;"
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

agent    "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :first
disabled #только до Лондона, гемор с бланком и правило интерлайна хитровыебанное - не первый перелет, а первый трансатлантический им надо
#newinterline
#unknown
#geo
not_implemented
commission "7%/5%"

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
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "XW", "SkyExpress Limited"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на собств.рейсы XW (В договоре Interline не прописан.)"
subagent "7% от опубл. тарифов на собств.рейсы XW"
commission "9%/7%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "9%/7%"

carrier "YM", "MONTENEGRO AIRLINES"
########################################

example 'svocdg'
agent    "8% от всех опубл. тарифов на рейсы YM (В договоре Interline не прописан.)"
subagent "5,6% от всех опубл. тарифов на рейсы YM"
commission "8%/5.6%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "8%/5.6%"

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
agent    "1% от опубл. тарифов на собств. рейсы ZI (В договоре Interline отдельно не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы ZI"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

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



end
