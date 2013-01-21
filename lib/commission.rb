# encoding: utf-8
class Commission
include Commission::Rules

# применяется вообще ко всем правилам ниже
defaults :system => :amadeus, :ticketing_method => "aviacenter", :consolidator => '2%', :blanks => 0, :discount => 0, :our_markup => 0, :corrector => :twopercent

carrier "SU", "Aeroflot"
########################################
# будут действовать на все правила в авиакомпании.
carrier_defaults :discount => 0

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
# применится только к этому правилу
# ticketing_method "direct"
discount "5.8%"
## our_markup 100
commission "7%/6%"

#subagent "5 (пять) руб. с авиабилета по специальным тарифам (субсидийным перевозкам) на рейсы авиакомпании SU и необходимым пакетом документов (в т.ч. при переоформлении авиабилета с доплатой по тарифу)."

example "svocdg/business"
important!
agent "- за продажу в Бизнес классе  9 % от тарифа;"
subagent "8 % от тарифов Бизнес класса, при переоформлении с доплатой по тарифам Бизнес класса;"
classes :business
discount "7%"
## our_markup 0
commission "9%/8%"

example "svocdg/su cdgsvo/ab"
agent "1.2. На рейсы других авиакомпаний по соглашениям «Интерлайн» при продаже перевозок в комбинации с рейсом под кодом «SU»:"
agent "- за продажу пассажирских перевозок по сквозным или участковым тарифам –   5 процентов от всего тарифа;"
agent "- при переоформлении авиабилета с доплатой по тарифу –  5  процентов  от суммы доплаты по тарифу."
subagent "• на рейсы Interline в комбинации с рейсом под кодом «SU»:"
subagent "(три) % от сквозных или участковых тарифов (в т.ч. при переоформлении авиабилета с       доплатой по тарифу)"
interline :yes
discount "1.7%"
## our_markup 100
commission "5%/3%"

example "cdgsvo/ab"
agent "1.3. На рейсы других авиакомпаний по соглашениям «Интерлайн» при продаже перевозок без комбинации с рейсом под кодом «SU»:"
agent "- 1 евро по курсу GDS на день выписки авиабилета) за авиаперевозку  (в рублевом эквиваленте, исчисляемом по расчетному курсу, установленному ОАО «Аэрофлот» на день оформления авиабилета с округлением до целого числа в большую сторону);"
agent "- 1 евро по курсу GDS на день выписки авиабилета) при переоформлении авиабилета с доплатой по тарифу (в рублевом эквиваленте, исчисляемом по расчетному курсу, установленному ОАО «Аэрофлот» на день оформления  авиабилета с округлением до целого числа в большую сторону); "
subagent "• на рейсы Interline без комбинации с рейсом под кодом «SU»:"
subagent "5 (пять) руб. с авиабилета (в т.ч. при переоформлении авиабилета с доплатой по тарифу)."
interline :absent
#discount '5'
## our_markup 100
commission "1eur/5"

example 'svosip/VV'
example 'odssvo svoods/VV'
check {includes(city_iatas, 'SIP ODS')}
interline :no, :yes, :absent
important!
no_commission "Катя просила выключить срочно от 14.06.12"

carrier "UN", "TRANSAERO"
########################################

example 'AERDME/W DMEAER/W'
example 'AERDME/Y DMEAER/M'
example 'AERDME/Y DMEAER/M'
example 'AERDME/W DMEAER/I'
example 'AERDME/N DMEAER/T'
example 'AERDME/W DMEAER/W'
agent "12% американский office-id"
subagent "10% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U."
subclasses "FPRJCADSLVXTNIGWUYHMQBKOE"
ticketing_method "downtown"
# disabled "срочно вырубаем DTT"
discount "9.5%"
commission "12%/10%"

# базовое вознаграждение ац
# example 'cdgsvo/r svocdg/f'
agent "12% от тарифа на рейсы Перевозчика по всем тарифам классов: Империал, Премиальный и Бизнес класс. FPRJCADSM"
subagent "9% от тарифа на рейсы Перевозчика по всем тарифам классов F, P, R, J, C, A, D, S, M"
subclasses "FPRJCADSM"
discount "8.8%"
disabled "На DTT выгодней"
commission "12%/9%"

# базовое вознаграждение ац
# example 'cdgsvo svocdg/y'
agent "7% от тарифа на рейсы Перевозчика по всем тарифам Эконом классов;"
subagent "5% от тарифа на рейсы Перевозчика по всем тарифам классов Y, H, Q, B, K, O;"
subclasses "YHQBKO"
discount "4.5%"
disabled "На DTT выгодней"
commission "7%/5%"

# базовое вознаграждение ац
# example 'cdgsvo/i svocdg/x'
agent "5% от тарифа на рейсы Перевозчика по всем тарифам Туристического класса;"
subagent "3% от тарифа на рейсы Перевозчика по всем тарифам классов L, V, X, T, N, I, G, W, U;"
subclasses "LVXTNIGWU"
discount "2.5%"
disabled "На DTT выгодней"
commission "5%/3%"

# Хьюстон-Сингапур
# example 'svoiws/UN7061'
# example 'svoaap/UN7061 aapsvo/UN7061'
# example 'dmesin/UN7062 sindme/UN7062'
strt_date "11.09.2011"
agent "9% до особых указаний от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса  между пунктами полетов ОАО «АК «ТРАНСАЭРО»  на территории России и Хьюстоном/Сингапуром (OW, RT)."
subagent "до особых указаний 7% от опубл. тарифов Эконом класса на собств. рейсы UN7061/7062 между Москвой и Хьюстоном/Сингапуром (OW, RT) и от опубл. сквозных тарифов для трансферных перевозок Эконом класса между пунктами полетов ОАО «АК «ТРАНСАЭРО» на территории России и Хьюстоном/Сингапуром (OW, RT)."
important!
check { includes_only(city_iatas, "MOW SIN HOU") } #FIX неполный чек
disabled "На DTT выгодней"
discount "6.5%"
commission "9%/7%"

# Пекин/Майами/Нью-Йорк
example 'TLVDME/T DMEJFK/T JFKDME/T DMETLV/T'
example "JFKDME"
example 'DMEMIA/FIRST/F MIADME/FIRST/F'
agent "12% Oт всех применяемых опубликованных тарифов на собственные  регулярные рейсы между Москвой и Пекином/Майами/Нью-Йорком (OW,RT)  и на сквозные перевозки между пунктами полетов АК  «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW,RT)."
subagent "10% от всех применяемых опубликованных тарифов между Москвой и Пекином/Майами/Нью-Йорком (OW.RT) и на сквозные перевозки между пунктами полетов АК «ТРАНСАЭРО» на территориях России, Украины, Казахстана, Узбекистана и Пекином/Майами/Нью-Йорком (OW.RT). (Через АСБ «GABRIEL»: установлен специальный «Код тура» NEWDE10 при продаже перевозок с полетными сегментами между Москвой-Майами/Нью-Йорком (OW/RT). СУБАГЕНТ обязан внести «Код тура» NEWDE10 для автоматического начисления комиссии.)"
important!
check { includes(city_iatas, %W(NYC MIA BJS LAX)) and includes(country_iatas, %W(RU UA KZ UZ)) }
discount "9.5%"
commission "12%/10%"

# интерлайн
example 'aerdme dmeaer/ab'
agent "5% Interline с участком Трансаэро. Без участка UN запрещено."
subagent "2% от тарифа на рейсы Interline c участком UN. Запрещена продажа на рейсы interline без
участка UN"
interline :yes
discount "2.5%"
commission "5%/3%"

example 'svocdg/lh cdgmad/lh'
interline :absent
no_commission

# код-шер с ZI трансфер по России
example 'svxory/f orysvx/f'
example 'svxory/un7357/f svxory/un7358/f'
example 'svxory/un7357/f'
example 'svxory/zi:un7358/f orysvx/zi:un7357/f'
example 'svxbcn/zi:un/f bcnsvx/zi:un/f'
example 'svxbcn/zi:un/s'
strt_date "21.10.2012"
expr_date "31.03.2013"
agent " С 21.10.12г. по 31.03.13г. на собств. рейсы UN и рейсы совместной эксплаутации с кодом UN (UN7357/UN7358) и в рамках код-шер соглашения с АК Aigle Azur (ZI). 12% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M  *от СКВОЗНЫХ тарифов (OW/RT) для ТРАНСФЕРНЫХ перевозок между пунктами полетов UN на территории РФ и нижеуказанными городами Европы" 
subagent "10% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subclasses "FPRJCADSM"
check { includes_only(country_iatas.first, 'RU') and includes(city_iatas, 'RIX VNO BER FRA VIE ALC BCN AGP MAD TCI PFO PED PAR VCE MIL ROM RMI LON') }
important!
discount "9.5%"
commission "12%/10%"

# код-шер с ZI прямые из столиц
example 'dmeory/f orydme/f'
example 'dmeory/un7357/f orydme/un7358/f'
example 'dmeory/un7357/f'
example 'dmeory/zi:un7358/f orydme/zi:un7357/f'
example 'svobcn/zi:un/f bcnsvo/zi:un/f'
example 'svobcn/zi:un/s'
strt_date "21.10.2012"
expr_date "31.03.2013"
agent " С 21.10.12г. по 31.03.13г. на собств. рейсы UN и рейсы совместной эксплаутации с кодом UN (UN7357/UN7358) и в рамках код-шер соглашения с АК Aigle Azur (ZI). 12% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M  *от опубл. тарифов (OW/RT) для ПРЯМЫХ перевозок между Москвой/Санк-Петербургом и нижеуказанными городами Европы"
subagent "10% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
agent "12% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent "10% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subclasses "FPRJCADSM"
check { includes_only(city_iatas.first, 'MOW LED') and includes(city_iatas, "RIX VNO BER FRA VIE ALC BCN AGP MAD TCI PFO PED PAR VCE MIL ROM RMI LON") }
important!
discount "9.5%"
commission "12%/10%"

# код-шер с ZI трансфер по России
# example 'svxcdg/zi:un7357/y cdgsvx/zi:un7358/h'
# example 'svxbcn/zi:un/h bcnsvx/zi:un/h'
# example 'svxbcn/zi:un/k'
strt_date "21.10.2012"
expr_date "31.03.2013"
agent "10% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subagent "8% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subclasses "YHQBKO"
check { includes_only(operating_carrier_iatas, 'ZI') and includes_only(country_iatas.first, 'RU') and includes(city_iatas, 'RIX VNO BER FRA VIE ALC BCN AGP MAD TCI PFO PED PAR VCE MIL ROM RMI LON') }
important!
disabled "на dtt выгоднее"
discount "7.5%"
commission "10%/8%"

# код-шер с ZI прямые из столиц
# example 'ledcdg/zi:un7357/y cdgled/zi:un7358/h'
# example 'ledbcn/zi:un/h bcnled/zi:un/h'
# example 'svobcn/zi:un/k'
strt_date "21.10.2012"
expr_date "31.03.2013"
agent "10% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subagent "8% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subclasses "YHQBKO"
check { includes_only(operating_carrier_iatas, 'ZI') and includes_only(city_iatas.first, 'MOW LED') and includes(city_iatas, 'RIX VNO BER FRA VIE ALC BCN AGP MAD TCI PFO PED PAR VCE MIL ROM RMI LON') }
important!
disabled "на dtt выгоднее"
discount "7.5%"
commission "10%/8%"

# код-шер с ZI трансфер по России
# example 'svxcdg/zi:un7357/l cdgsvx/zi:un7358/l'
# example 'svxbcn/zi:un/i bcnsvx/zi:un/i'
# example 'svxbcn/zi:un/w'
strt_date "21.10.2012"
expr_date "31.03.2013"
agent "С 11.11.2012г. 8% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U;"
subagent "3% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U;"
subclasses "LVXTNIGWU"
check { includes_only(operating_carrier_iatas, 'ZI') and includes_only(country_iatas.first, 'RU') and includes(city_iatas, 'RIX VNO BER FRA VIE ALC BCN AGP MAD TCI PFO PED PAR VCE MIL ROM RMI LON') }
important!
disabled "на dtt выгоднее"
discount "2.5%"
commission "8%/3%"

# код-шер с ZI прямые из столиц
# example 'svobcn/zi:un7357/i bcnsvo/zi:un/i'
# example 'svobcn/zi:un/i bcnsvo/zi:un/i'
# example 'svobcn/zi:un7357/w'
strt_date "21.10.2012"
expr_date "31.03.2013"
agent "С 11.11.2012г. 8% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U;"
subagent "3% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U;"
subclasses "LVXTNIGWU"
check { includes_only(operating_carrier_iatas, 'ZI') and includes_only(city_iatas.first, 'LED MOW') and includes(city_iatas, 'RIX VNO BER FRA VIE ALC BCN AGP MAD TCI PFO PED PAR VCE MIL ROM RMI LON') }
important!
disabled "на dtt выгоднее"
discount "2.5%"
commission "8%/3%"

# прямые из MOW, LED, OVB и SVX
example 'svobkk/c'
example 'svobkk/c bkksvo/c'
example 'ledhkt/m'
example 'ledhkt/m hktled/m'
example 'svxbkk/f'
example 'svxbkk/f bkksvx/f'
strt_date "21.11.2012"
expr_date "31.03.2012"
agent "15% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent "10% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subclasses "FPRJCADSM"
check { 
  (includes_only(city_iatas.first, 'MOW') and includes(city_iatas, 'SSH HRG BKK HKT DPS SGN GOI PUJ VRA CUN SYX MLE AUH AMM')) or
  (includes_only(city_iatas.first, 'LED') and includes(city_iatas, 'BKK HKT PUJ VRA')) or
  (includes_only(city_iatas.first, 'OVB') and includes(city_iatas, 'BKK HKT')) or
  (includes_only(city_iatas.first, 'SVX') and inlcudes(city_iatas, 'BKK HKT'))
}
important!
discount "9.5%"
commission "15%/10%"

# трансфер по России и в эти города (только через Москву)
example 'hmasvo/s svobkk/s'
example 'hmasvo/s svobkk/s bkksvo/s svohma/s'
strt_date "21.11.2012"
expr_date "31.03.2012"
agent "15% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subagent "10% от тарифа на рейсы UN по всем тарифам классов: F, P, R, J, C, A, D, S, M;"
subclasses "FPRJCADSM"
check { includes_only(country_iatas.first, 'RU') and includes(city_iatas, 'MOW SSH HRG BKK HKT DPS SGN GOI PUJ VRA CUN SYX MLE AUH AMM') }
important!
discount "9.5%"
commission "15%/10%"

# прямые из MOW, LED, OVB и SVX
# example 'svobkk/y'
# example 'svobkk/y bkksvo/y'
# example 'ledhkt/q'
# example 'ledhkt/q hktled/q'
# example 'svxbkk/o'
# example 'svxbkk/o bkksvx/o'
strt_date "21.11.2012"
expr_date "31.03.2012"
agent "10% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subagent "8% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subclasses "YHQBKO"
check { 
  (includes_only(city_iatas.first, 'MOW') and includes(city_iatas, 'SSH HRG BKK HKT DPS SGN GOI PUJ VRA CUN SYX MLE AUH AMM')) or
  (includes_only(city_iatas.first, 'LED') and includes(city_iatas, 'BKK HKT PUJ VRA')) or
  (includes_only(city_iatas.first, 'OVB') and includes(city_iatas, 'BKK HKT')) or
  (includes_only(city_iatas.first, 'SVX') and inlcudes(city_iatas, 'BKK HKT'))
}
important!
disabled "на dtt выгоднее"
discount "7.5%"
commission "10%/8%"

# трансфер по России и в эти города (только через Москву)
# example 'hmasvo/y svobkk/y'
# example 'hmasvo/y svobkk/y bkksvo/y svohma/y'
strt_date "21.11.2012"
expr_date "31.03.2012"
agent "10% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subagent "8% от тарифа на рейсы UN по всем тарифам классов: Y, H, Q, B, K, O;"
subclasses "YHQBKO"
check { includes_only(country_iatas.first, 'RU') and includes(city_iatas, 'MOW SSH HRG BKK HKT DPS SGN GOI PUJ VRA CUN SYX MLE AUH AMM') }
important!
disabled "на dtt выгоднее"
discount "7.5%"
commission "10%/8%"

# прямые из MOW, LED, OVB и SVX
# example 'svobkk/l'
# example 'svobkk/v bkksvo/v'
# example 'ledhkt/i'
# example 'ledhkt/i hktled/i'
# example 'svxbkk/g'
# example 'svxbkk/g bkksvx/g'
strt_date "21.11.2012"
expr_date "31.03.2012"
agent "8% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U"
subagent "6% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U."
subclasses "LVXTNIGWU"
check { 
  (includes_only(city_iatas.first, 'MOW') and includes(city_iatas, 'SSH HRG BKK HKT DPS SGN GOI PUJ VRA CUN SYX MLE AUH AMM')) or
  (includes_only(city_iatas.first, 'LED') and includes(city_iatas, 'BKK HKT PUJ VRA')) or
  (includes_only(city_iatas.first, 'OVB') and includes(city_iatas, 'BKK HKT')) or
  (includes_only(city_iatas.first, 'SVX') and inlcudes(city_iatas, 'BKK HKT'))
}
important!
disabled "на dtt выгоднее"
discount "5.5%"
commission "8%/6%"

# трансфер по России и в эти города (только через Москву)
# example 'hmasvo/n svobkk/n'
# example 'hmasvo/n svobkk/n bkksvo/n svohma/n'
strt_date "21.11.2012"
expr_date "31.03.2012"
agent "8% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U"
subagent "6% от тарифа на рейсы UN по всем тарифам классов: L, V, X, T, N, I, G, W, U."
subclasses "LVXTNIGWU"
check { includes_only(country_iatas.first, 'RU') and includes(city_iatas, 'MOW SSH HRG BKK HKT DPS SGN GOI PUJ VRA CUN SYX MLE AUH AMM') }
important!
disabled "на dtt выгоднее"
discount "5.5%"
commission "8%/6%"

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
strt_date "01.12.2012"
agent " 4% от всех опубликованных тарифов на рейсы 5N"
subagent "3% от всех опубликованных тарифов на рейсы 5N"
discount "2%"
commission "4%/3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :yes
discount "3.8%"
# our_markup 120
commission "7%/5%"

carrier "6H", "ISRAIR AIRLINE"
########################################

example 'svocdg'
strt_date "01.07.2011"
agent    "С 01.07.11г. 5% от всех опубл. тарифов на рейсы 6H (В договоре Interline отдельно не прописан.)"
subagent "С 01.07.11г. 3% от опубл. тарифов на собств.рейсы 6H"
discount "1%"
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

#example 'svocdg'
strt_date "11.04.2011"
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на собств. рейсы 7D;"
discount "2%"
disabled "out of BSP"
commission "5%/3.5%"

#example 'cdgsvo svocdg/ab'
strt_date "11.04.2011"
agent "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на интерлайн-перевозки как с участием собственных, так и без участия собственных рейсов (только рейсы интерлайн-партнёров) авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent "С 11.04.11г. 3,5% от всех опубл. тарифов на рейсы Interline с уч. собств. рейсов 7D;"
interline :yes, :absent
discount "2%"
disabled "out of BSP"
commission "5%/3.5%"

carrier "7W", "WINDROSE"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на собств.рейсы 7W"
subagent "6,3% от опубл. тарифов на собств.рейсы 7W"
discount "5%"
commission "9%/6.3%"

example 'svocdg cdgsvo/ab'
agent    "5% от всех опубл. тарифов на рейсы Interline c участком 7W"
subagent "3,5% от опубл. тарифов на рейсы Interline c участком 7W"
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
interline :no, :yes
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
check { includes(%W(US CA PR VI), country_iatas.first) }
our_markup "0.5%"
commission "0%/0%"

example 'miaiad iadmia/ab'
agent "Решили с Любой включить интерлайн, хотя он и не прописан"
subagent "Решили с Любой включить интерлайн, хотя он и не прописан"
interline :unconfirmed
our_markup "0.5%"
commission "0%/0%"

agent    "0% от тарифов VUSA, N1VISIT и N2VISIT."
subagent "0% от тарифов VUSA, N1VISIT и N2VISIT."
disabled "ни разу не попадались"
commission "0%/0%"

carrier "AB", "AIR BERLIN"
########################################

example 'cdgsvo svocdg'
example 'svocdg'
expr_date "28.02.2013"
agent    "5% по всем направлениям через DTT"
subagent "3% по всем направлениям через DTT"
interline :no
our_markup "25usd"
discount "1.7%"
ticketing_method "downtown"
commission "5%/3%"
 
# example 'cdgsvo svocdg'
# example 'cdgsvo/HG svocdg/HG'
strt_date "16.12.2012"
agent "С 16.12.12г. 1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent "С 16.12.12г. 5 коп с билета по опубл. тарифам на рейсы AB"
disabled "на dtt выгоднее"
commission "1/0.05"

example 'cdgsvo svocdg/lh'
agent    "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent "5 коп с билета по опубл. тарифам на рейсы AB"
interline :no, :unconfirmed
our_markup "1%"
# ticketing_method "direct"
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

carrier_defaults :consolidator => 0, :our_markup => '0.5%'

example 'svocdg'
example 'svocdg cdgsvo/ab'
strt_date "01.07.2012"
agent    "1 руб. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ;"
agent    "1 руб. за билет,выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ, 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
commission "1/0.05"

example 'cdgsvo/ab'
no_commission

carrier "AM", "AEROMEXICO"
########################################

carrier_defaults :discount => 0

example "SVOCDG"
agent    "9% от всех опубликованных тарифов"
subagent "7% от опубл. тарифов на рейсы AM"
interline :no, :yes
discount "6.5%"
commission "9%/7%"

carrier "AY", "FINNAIR"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета на рейсы AY (Билеты «Интерлайн» под кодом АY могут быть выписаны только в случае использования опубл. тарифов или тарифов ИАТА и только при условии, если АY выполняет хотя бы один рейс при наличии действующих «Интерлайн» соглашений с другими а/к, задействованными в перевозке.)"
subagent "50 коп. с билета на рейсы AY"
interline :no, :yes
our_markup "0.2%"
commission "1/0.5"

example 'cdgsvo/ab'
no_commission

carrier "AZ", "ALITALIA"
########################################
carrier_defaults :consolidator => 0

example 'mrucdg'
example 'mrucdg cdgmru'
agent    "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
our_markup "0.5%"
commission "1eur/5"

example 'svocdg cdgsvo/ab'
agent    "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
our_markup "0.5%"
commission "1eur/5"

example 'ledlcc/economy'
example 'dmevrn/business vrndme'
strt_date "19.10.2012"
expr_date "30.11.2012"
agent "10% от тарифа на все направления Alitalia (Эконом и Бизнес класса) с началом путешествия из Москвы и Санкт-Петербурга (тарифы туда и обратно, а также тарифы в одну сторону, но с вылетом из Москвы или Санкт-Петербурга). Повышенная комиссия не применяется, если начало путешествия не из Москвы или Санкт-Петербурга.
Период  путешествия с 01.11.12г.по 31.12.2012г. (последный день вылета) на следующие направления"
subagent "8% от тарифа на все направления Alitalia (Эконом и Бизнес класса) с началом путешествия из Москвы и Санкт-Петербурга (тарифы туда и обратно, а также тарифы в одну сторону, но с вылетом из Москвы или Санкт-Петербурга). Повышенная комиссия не применяется, если начало путешествия не из Москвы или Санкт-Петербурга.
Период путешествия с 01.11.12г.по 31.12.2012г. (последный день вылета) на следующие направления:"
classes :business, :economy
check { includes(city_iatas.first, "MOW LED") }
important!
commission "10%/8%"

example 'svocdg/ab cdgsvo'
no_commission

carrier "B2", "Belavia"
########################################

example 'svocdg'
agent    "5% от всех опубл. тарифов на собств. рейсы B2;"
subagent "3,5% от всех опубл. тарифов на собств. рейсы B2;"
#discount "1.5%"
commission "5%/3.5%"

carrier "BA", "BRITISH AIRWAYS (См. в конце таблицы продолжение в 4-х частях)"
########################################

example 'svocdg'
agent    "1 euro с билета по опубл. тарифам на собств. рейсы BA;"
subagent "5 руб. с билета по опубл. тарифам на собств. рейсы BA; Сбор Агента 2% от тарифа."
our_markup "20"
commission "1eur/5"

example 'svocdg cdgsvo/ab'
agent    "1 euro с билета по опубл. тарифам на рейсы Interline, с участком BA. (British Airways и другие перевозчики (oneworld и авиакомпании имеющие договор interline с British Airways), выписанные на одном бланке. Правило первого перевозчика не является обязательным, то есть первый перелет может быть выполнен другой авиакомпанией. Не  разрешается использование бланков ВА для выписки других перевозчиков (даже авиакомпаний членов альянса oneworld, кроме Qantas) без участия ВА. Нарушение этого правила повлечет за собой ADM на сумму GBP 25."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline, с участком BA. Сбор Агента 2% от тарифа."
interline :yes
our_markup "20"
commission "1eur/5"

carrier "BD", "BMI"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.2%', :disabled => 'вышли из BSP'

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета по опубл.тарифам"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы BD и рейсы Interline с участком BD"
interline :no, :yes
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
interline :no, :yes
our_markup "20"
commission "1/0.5"

example 'cdgsvo/ab'
no_commission

carrier "CA", "AIR CHINA"
########################################

example 'svopek/f'
example 'svopek/a peksvo/f'
example 'svopek/c peksvo/d'
agent   "15% от опубл. тарифов по классам F/A/C/D на собств. рейсы CA;"
subagent "13,5% от опубл. тарифов по классам F/A/C/D на собств. рейсы CA;"
subclasses "FACD"
discount "8%" 
check { includes(city_iatas.first, 'MOW') }
commission "15%/13.5%"

example 'svopek/z'
example 'svopek/w peksvo/h'
example 'svopek/k peksvo/f'
agent   "12% от опубл. тарифов по классам Z/W/Y/B/M/H/K/L на собств. рейсы СА;"
subagent "11,5% от опубл. тарифов по классам Z/W/Y/B/M/H/K/L на собств. рейсы СА;"
subclasses "FACDZWYBMHKL"
discount "7%"
check { includes(city_iatas.first, 'MOW') }
commission "12%/11.5%"

example 'svopek/q'
example 'svopek/g peksvo/s'
example 'svopek/u peksvo/f'
example 'svopek/s peksvo/a'
agent   "10% от опубл. тарифов по классам Q/G/V/S/U на собств. рейсы СА."
subagent "8,5% от опубл. тарифов по классам Q/G/V/S/U на собств. рейсы СА."
subagent "FACDZWYBMHKLQGVSU"
discount "4%"
check { includes(city_iatas.first, 'MOW') }
commission "10%/8.5%"

example 'ledpek'
example 'ledpek pekled'
agent "9% Все международные перелеты рейсами СА из России, за исключением вылетов из Москвы."
subagent "7% Все международные перелеты рейсами СА из России, за исключением вылетов из Москвы."
important!
check { includes(country_iatas.first, 'RU') and not includes(city_iatas.first, 'MOW') }
discount "5%"
commission "9%/7%"

example 'okopek/ab pekoko'
example 'pekycu ycupek'
example 'peksgn'
agent   "3%  от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
subagent "2% от опубл. тарифов на все остальные рейсы СА при обязательном наличии собств.сегмента СА;"
interline :no, :yes
commission "3%/2%"

example 'okopek/ab'
agent "  0% интерлайн без участия авиакомпании  CA ."
subagent "  0% интерлайн без участия авиакомпании  CA ."
interline :absent
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
agent    "7% от всех опубликованных и специальных тарифов"
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
discount "4.5%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "7% от всех опубликованных и специальных тарифов"
subagent "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским   тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
interline :no, :yes
discount "4.5%"
commission "7%/5%"

carrier "CY", "CYPRUS AIRWAYS"
########################################

example 'svocdg'
agent    "9% от всех опубл. тарифов на рейсы CY. (В договоре Interline не прописан.)"
subagent "7% от опубликованных тарифов на рейсы CY."
discount "6%"
commission "9%/7%"

example 'cdgsvo svocdg/ab'
agent "??? 1р Interline не прописан"
subagent "??? 0р Interline не прописан"
interline :unconfirmed
discount "6%"
commission "9%/7%"

carrier "CZ", "CHINA SOUTHERN"
########################################

example 'svocdg'
agent    "9% от тарифа на рейсы, полностью выполняемые CZ;"
subagent "7% от тарифа на рейсы, полностью выполняемые CZ;"
discount "6.5%"
commission "9%/7%"

example 'cdgsvo svocdg/ab'
agent    "7% от тарифа на рейсы CZ с участием других перевозчиков;"
subagent "5% от тарифа на рейсы CZ с участием других перевозчиков;"
interline :yes
discount "4%"
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
discount "4.5%"
commission "7%/5%"

example 'svocdg/business'
agent    "9% от опубл. тарифов бизнес класса на собств. рейсы D9"
subagent "6,3% от опубл. тарифов бизнес класса на собств. рейсы D9"
classes :business
discount "5.5%"
commission "9%/6.3%"

example 'svocdg cdgsvo/ab'
example 'svocdg/business cdgsvo/ab'
agent    "2% от опубл. тарифов на рейсы Interline с участком D9"
subagent "1,4% от опубл. тарифов на рейсы Interline с участком D9"
interline :yes
discount "1%"
commission "2%/1.4%"

carrier "DE", "Condor Flugdienst (Авиарепс)"
########################################

example 'svocdg'
strt_date "01.10.2011"
agent    "1руб от всех опубл. тарифов на рейсы DE. (В договоре Interline не прописан.)"
subagent "5 коп от опубл. тарифа на рейсы DE."
commission "1/0.05"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.05"

carrier "DL", "DELTA AIRLINES"
########################################

example 'svojfk/s'
example 'svojfk/i jfksvo/s'
agent "10%"
subagent "8%"
subclasses "SIQKLUT"
check { includes_only(country_iatas.first, "RU") and includes(country_iatas, "US") }
ticketing_method "downtown"
discount "7.5%"
commission "10%/8%"

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
interline :no, :yes
check { includes(%W(europe asia africa), Country[country_iatas.first].continent ) }
## discount "0.3%"
commission "1%/0.5%"

example 'miadtw dtwmia'
example 'miadtw dtwmia/ab'
agent    "1% от опубл. тарифа DL при внутренних перелетах по США"
subagent "0,5% от опубл. тарифа DL при внутренних перелетах по США"
interline :no, :yes
domestic
## discount "0.3%"
commission "1%/0.5%"

example 'cdgsvo/ab'
agent    "1% от опубл. тарифа на рейсы Interline без участка DL."
subagent "0,5% от опубл. тарифа на рейсы Interline без участка DL."
interline :absent
## discount "0.3"
commission "1%/0.5%"

example 'EWRDTW DTWYYZ' # ньюйорк - детройт - торонто
agent    "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
subagent "0% на перевозки, нач.в США (включая Пуэрто Рико, Острова Вирджинии и Канада)"
interline :no, :yes
check { includes(%W(PR US VI CA), country_iatas.first) }
commission "0%/0%"

carrier "EK", "EMIRATES"
########################################

carrier_defaults :consolidator => 0

example 'svocdg/first cdgsvo/business'
example 'svocdg/first cdgsvo/first'
agent    "5% от тарифов Первого и Бизнес классов на рейсы EK;"
subagent "3,5% от тарифов Первого и Бизнес классов на рейсы EK;"
classes :first, :business
discount "2%"
commission "5%/3.5%"

example 'svocdg/business cdgsvo'
example 'svocdg/first cdgsvo'
agent    "5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
subagent "3,5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
discount "2%"
commission "5%/3.5%"

example 'svocdg'
important!
agent    "1 руб. с билета по опубл.тарифам Эконом класса на рейсы EK."
subagent "5 коп. с билета по опубл.тарифам Эконом класса на собств. рейсы EK."
classes :economy
our_markup '20'
commission "1/0.05"

agent    "(Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "???"
example 'svocdg cdgsvo/ab'
example 'svocdg/business cdgsvo/ab/business'
interline :half
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
discount "3%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "5 % от опубл. тарифов на рейсы Interline с участком ET"
subagent "3,5 % от опубл. тарифов на рейсы Interline с участком ET"
interline :yes
discount "2%"
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
discount "3%"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
discount "3%"
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
## discount "1.5%"
commission "4%/2.8%"

example 'cdgsvo svocdg/ab'
agent "??? 1р Interline не прописан"
subagent "??? 0р Interline не прописан"
interline :unconfirmed
## discount "1.5%"
commission "4%/2.8%"

carrier "FI", "ICELANDAIR  (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1% от всех опубл. тарифов на рейсы FI (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы FI"
commission "1%/0.5%"

example 'cdgsvo svocdg/ab'
agent "1% от опубл. тарифов на рейсы Interline с обязательным участием FI."
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "FV", "RUSSIA"
########################################

## carrier_defaults our_markup: 30

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent "7% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
subagent "5% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
discount "4.8%"
commission '7%/5%'

example 'ledsvo/business svoled/business'
expr_date "30.03.2013"
agent "9% от опубл.тарифов Бизнес класса на собств.рейсы FV, внутренние и международные, ИСКЛЮЧАЯ рейсы «CODE-Share»."
subagent "7% от опубл.тарифов Бизнес класса на собственные рейсы FV, внутренние и международные, ИСКЛЮЧАЯ рейсы «CODE-Share»."
important!
classes :business
domestic
discount "6.5%"
commission '9%/7%'

example 'svocdg/ab'
agent "1 euro с билета на рейсы Interline без участка FV."
subagent "1 руб. с билета на рейсы Interline без участка FV."
interline :absent
## discount '1'
commission "1eur/1"

carrier "GF", "GULF AIR (Глонасс) (НЕ BSP!!!)"
#######################################
carrier_defaults :disabled => 'не BSP'

agent    "7% от тарифа на международные рейсы GF"
subagent "5% от тарифа на международные рейсы GF"
interline :no
commission "7%/5%"

agent    "5% от тарифа на рейсы GF между аэропортами Персидского залива"
subagent "3,5% от тарифа на рейсы GF между аэропортами Персидского залива"
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

# carrier_defaults :ticketing_method => "direct"

# включено с дополнительной проверкой
agent    "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent    "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent    "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent "5 коп. с билета по опубл. тарифам HR"
interline :absent
our_markup "30"
commission "1/0.05"

carrier "HU", "HAINAN AIRLINES"
########################################

example 'svopek/c'
example 'svopek/c/ab peksvo/c'
strt_date "12.12.2011"
agent "20% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "18% от опубл.тарифов по классу С на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "C"
interline :no, :yes
check { includes(city_iatas.first, 'MOW') and includes(country_iatas, 'CN') }
discount "15%"
commission "20%/18%"

example 'svopek/d'
example 'svopek/d/ab persvo/d'
example 'svopek/i/ab peksvo/i'
strt_date "12.12.2011"
agent "15% от опубл.тарифов по классу D на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "13% от опубл.тарифов по классу D на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "DI"
interline :no, :yes
check { includes(city_iatas.first, 'MOW') and includes(country_iatas, 'CN') }
discount "10%"
commission "15%/13%"

example 'svopek/z'
example 'svopek/z/ab peksvo/z'
strt_date "12.12.2011"
agent "9% от опубл.тарифов по классам I,Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "7% от опубл.тарифов по классам I,Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subclasses "Z" 
interline :no, :yes
check { includes(city_iatas.first, 'MOW') and includes(country_iatas, 'CN') }
discount "5%"
commission "9%/7%"

# копия для эконом класса
example 'svopek'
example 'svopek/ab peksvo'
example 'svopek/ab peksvo'
strt_date "12.12.2011"
agent "9% от опубл.тарифов по классам I,Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
subagent "7% от опубл.тарифов по классам I,Z, а также на Эконом классы на собств.рейсы HU по маршруту MOW - CHINA или MOW - CHINA - MOW"
interline :no, :yes
check { includes(city_iatas.first, 'MOW') and includes(country_iatas, 'CN') }
discount "5%"
commission "9%/7%"

example 'ledpek/c pekled/c'
example 'ledpek/c/ab pekled/c'
example 'ledpek/d/ab pekled/d'
example 'ledpek/i/ab pekled/i'
example 'ledpek/z/ab pekled/z'
strt_date "12.12.2011"
agent "15% от опубл.тарифов по классу С,D,I,Z на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "13% от опубл.тарифов по классу С,D,I,Z на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
subclasses "CDIZ"
interline :no, :yes
check { includes(city_iatas.first, 'LED') and includes(country_iatas, 'CN') }
discount "11%"
commission "15%/13%"

example 'ledpek pekled'
example 'ledpek/ab pekled'
strt_date "12.12.2011"
agent "9% от на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или  LED-CHINA-LED"
subagent "7% на Эконом классы на собств.рейсы HU по маршруту LED-CHINA или LED-CHINA-LED"
interline :no, :yes
check { includes(city_iatas.first, 'LED') and includes(country_iatas, 'CN') }
discount "4%"
commission "9%/7%"

example 'ovbpek/c'
example 'kjapek/d'
example 'iktpek/i pekikt/i/ab'
example 'ovbpek/z pekovb/z/ab'
strt_date "10.11.2011"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subclasses "CDIZ"
interline :no, :yes
check { includes(%W(KJA OVB IKT), city_iatas.first) }
discount "4%"
commission "9%/7%"

# копия для эконом класса
example 'ovbpek'
example 'kjapek'
example 'iktpek pekikt/ab'
example 'ovbpek pekovb/ab'
strt_date "10.11.2011"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Новосибирск-CHINA или  Новосибирск-CHINA-Новосибирск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Иркутск-CHINA или  Иркутск-CHINA-Иркутск"
agent "9% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Новосибирск-CHINA или Новосибирск-CHINA-Новосибирск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Иркутск-CHINA или Иркутск-CHINA-Иркутск"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Красноярск-CHINA или Красноярск-CHINA-Красноярск"
interline :no, :yes
check { includes(%W(KJA OVB IKT), city_iatas.first) }
discount "4%"
commission "9%/7%"

example 'alapek/c'
example 'alapek/d'
example 'alapek/i pekala/i/ab'
example 'alapek/z pekala/z/ab'
strt_date "10.11.2011"
agent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subclasses "CDIZ"
interline :no, :yes
check { includes(city_iatas.first, 'ALA') }
discount "4%"
commission "7%/7%"

# копия для эконом класса
example 'alapek'
example 'alapek'
example 'alapek pekala/ab'
example 'alapek pekala/ab'
strt_date "10.11.2011"
agent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классына собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
subagent "7% от опубл.тарифов по классу С,D,I,Z, а также на Эконом классы на собств.рейсы HU по маршруту Алма-Ата-CHINA или Алма-Ата-CHINA-Алма-Ата"
interline :no, :yes
check { includes(city_iatas.first, 'ALA') }
discount "4%"
commission "7%/7%"

example 'pekweh'
example 'nayweh wehnay'
agent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
check { includes_only(country_iatas, 'CN') and includes(city_iatas.first, 'BJS') }
domestic
commission "0%/0%"

example 'miapek'
agent "3% начало перелета из третьей страны в Китай на все классы"
subagent "1% начало перелета из третьей страны в Китай на все классы"
check { not includes(country_iatas.first, 'CN') and includes(country_iatas, 'CN') }
commission "3%/1%"

strt_date "01.01.2013"
agent "9% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent "7% от опубл. тарифов на собств. рейсы HU"
commission "9%/7%"

carrier "HX", "Hong Kong Airlines"
########################################

example 'dmehkg hkgdme/ab'
agent "7% от всех опубликованных тарифов на собственные рейсы HX  и рейсы Interline с участком HX (в/из России). (Без участка HX    интерлайн выписывать запрещено!)"
subagent "5% от опубл. тарифов на совбств. рейсы HX"
check { includes(country_iatas, 'RU') }
interline :yes
discount "3%"
commission "7%/5%"

example 'SVOHKG/BUSINESS/J HKGSVO/BUSINESS/J'
agent "C 15.06.11г. 15% от опубликованных тарифов Бизнес класса (RBD: C,D,J) на собственные рейсы HX (RT или OW)."
subagent "C 15.06.11г. 12% от опубл. тарифов Бизнес класса (RBD: C,D,J) на собств. рейсы HX (RT или OW)."
classes :business
subclasses "CDJ"
important!
discount "8%"
commission "15%/12%"

example 'svocdg'
agent    "7% от всех опубл. тарифов на собств.рейсы HX (В договоре Interline не прописан.)"
subagent "5% от опубл. тарифов на собств.рейсы HX"
discount "3%"
commission "7%/5%"

carrier "HY", "UZBEKISTAN AIRWAYS (Узбекистон Хаво Йуллари) (НЕ BSP!!!)"
########################################
carrier_defaults :disabled => "не BSP"

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы HY"
subagent "5% от опубл. тарифов на собств. рейсы HY"
discount "3%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent    "0% от опубл. тарифов на рейсы Interline"
subagent "0% от опубл. тарифов на рейсы Interline"
interline :yes
commission "0%/0%"

carrier "IB", "IBERIA"
########################################

carrier_defaults :consolidator => 0, :our_markup => '1%'

example 'svocdg cdgsvo'
agent    "1 руб. с билета на рейсы IB. (Билеты Interline под кодом IB могут быть выписаны только в случае существования опубл. тарифов и только при условии, что IB выполняет первый рейс маршрута."
subagent "50 коп. с билета на рейсы IB"
commission "1/0.5"

carrier "IG", "MERIDIANA (РИНГ-АВИА)"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств.рейсы IG (В договоре Interline не прописан.)"
subagent "3,5% от опубл. тарифов на собств.рейсы IG"
discount "1.5%"
commission "5%/3.5%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
discount "1.5%"
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
discount "3%"
commission "7%/5%"

example 'svooko okosvo/ab'
agent    "7% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
agent    "Оформление авиабилетов на бланках JAL по Interline  (в случае наличия рейсов других авиакомпаний) возможно  при условии  наличия  соглашения с соответствующей авиакомпанией и хотя бы одного сегмента с международным рейсом JAL."
agent    "Комиссия 7%, в этом случае,  выплачивается только, если авиабилет оформлен по опубликованным тарифам IATA (если при расчете тарифа используются  carrier fares"
agent    "других авиакомпаниях, то комиссия с них не выплачивается)."
subagent "5% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
interline :yes
discount "3%"
commission "7%/5%"

example 'okoaoj'
agent    "5% от тарифов на внутренние рейсы по Японии"
subagent "3,5% от тарифов на внутренние рейсы по Японии"
domestic
discount "2%"
commission "5%/3.5%"

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
subagent "JU  С 21.02.2011г. 5% от опубл. тарифов на собств. рейсы JU"
discount "4%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
agent "С 15.02.2011г. 0% от опубл. тарифов на рейсы Interline"
subagent "С 21.02.2011г. 0% от опубл. тарифов на рейсы Interline"
interline :yes
commission "0%/0%"

carrier "KC", "Air Astana"
########################################

example 'tsekgf'
strt_date "11.06.2012"
agent    "С 11.06.12г. 4% от опубл. тарифа на собств. рейсы КС по маршрутам внутри Республики Казахстан;"
subagent "3% от тарифа по маршрутам внутри Республики Казахстан;"
domestic
discount "2%"
commission "4%/3%"

example 'svoala alasvo'
strt_date "11.06.2012"
agent    "С 11.06.12г. 1 евро с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам"
subagent "С 11.06.12г. 5 руб. с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам;"
commission "1eur/5"

example 'svoala/ab alasvo'
strt_date "11.06.2012"
agent    "С 11.06.12г. 1 евро с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
subagent "С 11.06.12г. 5 руб. с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
interline :yes
commission "1eur/5"

example 'svoala/qr alasvo/qr'
strt_date "11.06.2012"
agent "С 11.06.12г. 4% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
subagent "С 11.06.12г. 3% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
interline :absent
check { includes_only(marketing_carrier_iatas, 'QR' ) }
commission "4%/3%"

carrier "KE", "KOREAN AIR"
########################################

example 'svogmp'
agent "С 01.04.2011г. 5% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
subagent "С 01.04.2011г. 3% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
check { includes(country_iatas.first, 'RU') }
discount "2.5%"
commission "5%/3%"

example 'gmpsvo'
agent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
subagent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
check { not includes(country_iatas.first, 'RU') }
commission "0%/0%"

example 'svoicn icnsvo/ab'
no_commission

carrier "KL", "KLM"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.5%'

example 'svocdg'
agent    "1руб за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 1руб за билет, выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
commission "1/0.05"

carrier "KM", "AIR MALTA  (Авиарепс)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собств. рейсы KM"
subagent "0,5% от опубл. тарифа на рейсы KM"
## discount "0.2%"
commission "1%/0.5%"

example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на рейсы Interline"
subagent "0,5% от опубл. тарифа на рейсы Interline"
interline :yes
## discount "0.2%"
commission "1%/0.5%"

carrier "LA", "LAN Airlines"
########################################

example 'svocdg'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LA"
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
commission "1/0.05"

example 'svocdg/ab cdgsvo'
agent    "1 руб. с билета по опубл. тарифам на рейсы Interline c участком LA. Interline под кодом LA может быть выписан только при условии, что LA выполняет как минимум один рейс. За несоблюдение данного условия будет начислен штраф в размере EUR200."
agent    "Оформление отдельного авиабилета на рейсы других перевозчиков в пределах региона Южная и Центральная Америка на электронном стоке  LA ВОЗМОЖНО при условии, что внешний участок, т.е. межконтинентальный перелет, осуществляется авиакомпанией LAN. При выписке разными бланками внешнего и внутренних перелетов, все сегменты должны фигурировать в одном бронировании."
agent    "Также необходимо проверять наличие MITA и BITA соглашений. В других случаях оформление авиабилетов по интерлайн соглашению на электронном стоке авиакомпании LAN Airlines (045) не разрешено."
agent    "Комиссия при оформлении авиабилетов по Interline на электронном стоке авиакомпании LAN Airlines (045) во всех случаях составляет 1 руб. Авиакомпания вправе начислить штраф (ADM) за нарушение правил оформленная билета, неверную калькуляцию и т.п."
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
interline :no, :yes
commission "1/0.05"

carrier "LH", "LUFTHANSA"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.5%'

example 'dmejfk/Q'
example 'dmejfk/Q jfkdme/ua/Q'
agent    "через DTT из России в США и наоборот - 10% (кроме участков US)"
subagent "через DTT из России в США и наоборот - 8%"
check { includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') and not includes(marketing_carrier_iatas, 'US')}
subclasses "FADZPQVWSTLK"
interline :no, :yes
our_markup "0"
discount '6.9%'
ticketing_method "downtown"
commission "10%/8%"

example 'dmejfk'
example 'dmejfk jfkdme/ua/L'
agent    "через DTT из России в США и наоборот - 5% (кроме участков US)"
subagent "через DTT из России в США и наоборот - 3%"
check { includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') and not includes(marketing_carrier_iatas, 'US')}
#subclasses "YBMUH"
interline :no, :yes
our_markup "0"
discount '1.5%'
ticketing_method "downtown"
commission "5%/3%"

example 'dmebcn'
example 'bcndme dmebcn/OS'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
check { includes(country_iatas, 'ES FR IT CZ PT NL CH') } 
interline :no, :yes
our_markup "20"
## discount '5%'
commission "1/0.05"

example 'svooko'
example 'svooko okosvo/ab'
example 'dmejfk jfkdme/US'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
interline :no, :yes
## discount '0.05'
commission "1/0.05"

example 'svocdg/LX'
example 'svocdg/EW'
example 'svocdg/CL'
example 'svocdg/IQ'
example 'svocdg/C3'
agent    "1 руб. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
subagent "5 коп. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
interline :absent
check { includes_only(marketing_carrier_iatas, %W[LX EW CL IQ C3]) }
## discount '0.05'
commission "1/0.05"

example 'svocdg/ab'
no_commission

carrier "LO", "LOT"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.5%'

example 'svocdg'
agent    "1 ЕВРО от продаж опубликованных или ИАТА тарифов. Interline - как минимум один международный сегмент выполняется Перевозчиком."
subagent "5 руб. с билета по опубл. тарифам на рейсы LO;"
our_markup "20"
commission "1eur/5"

example "svocdg cdgsvo/ab"
agent "Interline - как минимум один международный сегмент выполняется Перевозчиком."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline с участком LO."
interline :yes
our_markup "20"
commission "1eur/5"

carrier "LX", "SWISS"
########################################

carrier_defaults :consolidator => 0, :our_markup => '1%'

example 'dmejfk/Q'
example 'dmejfk/Q jfkdme/os/Q'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check {includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') }
subclasses "FADZPQVWSTLK"
interline :no, :yes
our_markup "0"
discount '6%'
ticketing_method "downtown"
commission "10%/8%"

example 'dmejfk'
example 'dmejfk jfkdme/os/L'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check {includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') } 
#subclasses "YBMUH"
interline :no, :yes
our_markup "0"
discount '1%'
ticketing_method "downtown"
commission "5%/3%"

example 'dmebcn'
example 'bcndme dmebcn/lh'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX.
(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
check {includes(country_iatas, 'ES FR IT CZ PT NL CH') } #CHECKME wtf?
interline :no, :yes
our_markup "20"
## discount '5%'
commission "1/0.05"

example 'svooko okosvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX.
(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
interline :no, :yes
#FIXME с этой странной доплатой выше - что?
commission "1/0.05"

carrier "LY", "EL AL ISRAEL AIRLINES"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов Эконом класса на рейсы LY"
subagent "3,5% от опубл. тарифов Эконом класса на рейсы LY"
classes :economy
discount "2%"
commission "5%/3.5%"

example 'svocdg/j cdgsvo/j'
agent    "5% от опубл. тарифов Бизнес класса J на рейсы LY"
subagent "3,5% от опубл. тарифов Бизнес класса J на рейсы LY"
subclasses "J"
important!
discount "1%"
commission "5%/3.5%"

example 'svocdg/business cdgsvo/business'
agent    "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
classes :business
discount "4.5%"
commission "9.7%/6.7%"

example 'svocdg cdgsvo/business'
example 'svocdg cdgsvo/ab'
no_commission

carrier "MA", "MALEV"
########################################

carrier_defaults :consolidator => 0, :our_markup => '1%'

example "svobud/c budsvo/c"
agent "12% от тарифа по классам J,C,D,I,Y,B;"
subagent ""
subclasses "JCDIYB"
disabled "no subagent"
commission "12%/0%"

example "svobud/k budsvo/k"
agent "6% от тарифа по классам K,M,L,V,S,Z, N."
subagent ""
subclasses "KMLVSZN"
disabled "no subagent"
commission "6%/0%"

example "svobud budsvo/ab"
agent    "1 руб. с билета от опубл., конфиде.тарифов Эконом и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
subagent "5 коп. с билета от опубл., конфиде.тарифов Экономического и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
interline :half
disabled "ибо обанкротились (Люба сказала)"
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
check { includes(city_iatas.first, 'MOW') }
discount "6%"
commission "9%/7%"

example 'caisvo svocai'
agent    "5% от тарифа на рейсы MS из Египта"
subagent "3,5% от тарифа на рейсы MS из Египта"
international
check { includes(country_iatas.first, 'EG') }
discount "2%"
commission "5%/3.5%"

example 'cdgcai'
agent    "5% от тарифа для иных международных рейсов MS"
subagent "3,5% от тарифа для иных международных рейсов MS"
international
discount "2%"
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

example 'svohkg/business'
example 'svohkg/business hkgmfm/business'
example 'svotsa/business'
example 'svotsa/business tsahkg/business'
example 'svotpe/business'
strt_date "15.09.2011"
agent "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 9%"
subagent "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 7%"
classes :business
check { includes(country_iatas, %W(TW HK MO)) }
discount "4.5%"
commission "9%/7%"

example 'ledhkg/economy'
example 'ledtsa/economy'
example 'ledtpe/economy'
agent "MU междунар или регион-ные* рейсы Экономический  класс – 7%"
subagent "MU междунар или регион-ные* рейсы Экономический класс – 5%"
classes :economy
check { includes(country_iatas, %W(TW HK MO)) }
discount "3.5%"
commission "7%/5%"

example 'ledhkg/economy hkgled/business'
agent "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 7%"
subagent "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 5%"
classes :economy, :business
check { includes(country_iatas, %W(TW HK MO)) }
discount "3.5%"
commission "7%/5%"

example 'svohkg hkgsvo/ab'
example 'svomfm/ab mfmsvo'
agent "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 5%"
subagent "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 3%"
interline :yes
discount "2%"
commission "5%/3%"

example 'shacan'
agent "MU только внутр. перелет по территории КНР – 1 EUR"
subagent "MU только внутр. перелет по территории КНР – 5 руб"
domestic
commission "1eur/5"

example 'svohkg/ab'
agent "Рейсы Других авиакомпаний  – 1 EUR"
subagent "Рейсы Других авиакомпаний – 5 руб"
interline :absent
commission "1eur/5"

carrier "NN", "VIM-Airlines"
########################################

example 'svocdg cdgsvo'
agent "5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
subagent "3,5% от всех опубл. тарифов по другим маршрутам на собств.рейсы NN"
discount "2.8%"
commission "5%/3.5%"

example 'svocdg/ab cdgsvo'
agent "Интерлайн не прописан"
subagent "Интерлайн не прописан"
interline :unconfirmed
commission "1/0"

carrier "NZ", "AIR NEW ZEALAND (НЕ BSP!!!)"
########################################

example 'svocdg cdgsvo'
agent    "7% от тарифа на международные перелеты на рейсы NZ;"
subagent "5% от тарифа на международные перелеты на рейсы NZ;"
international
discount "3%"
commission "7%/5%"

example 'dudbhe bhedud'
agent    "5% от тарифа на внутренние перелеты на рейсы NZ."
subagent "3,5% от тарифа на внутренние перелеты на рейсы NZ."
domestic
discount "2%"
commission "5%/3.5%"

carrier "OA", "OLYMPIC AIR (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "1% от опубл. тарифов на собственные рейсы OA (В договоре Interline не прописан.)"
subagent "5 руб. с билета по опубл. тарифам на собств.рейсы OA"
commission "1%/5"

example 'cdgsvo svocdg/ab'
agent "1% от опубл. тарифов на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
interline :yes
commission "1%/5"

example 'cdgsvo/ab svocdg/ab'
no_commission

carrier "OK", "CZECH AIRLINES"
########################################

example "svoosr osrsvo"
strt_date "15.10.2012"
expr_date "31.03.2013"
agent "6% от тарифа на авиабилеты, выписанные по опубл. тарифам
на все транзитные перевозки с вылетом из городов Российской Федерации
и распространяется на рейсы совместной эксплуатации (код-шеринговые рейсы).
Повышенное вознаграждение НЕ применяется к билетам с конечным пунктом назначения Прага и Карловы Вары.
Данное вознаграждение распространяется на авиабилеты, выписанные в период с 15.10.12г. по 31.03.2013г. (включая обе даты)"
subagent "4% от тарифа на авиабилеты, выписанные по опубл. тарифам
на все транзитные перевозки с вылетом из городов Российской Федерации
и распространяется на рейсы совместной эксплуатации (код-шеринговые рейсы).
Повышенное вознаграждение НЕ применяется к билетам с конечным пунктом назначения Прага и Карловы Вары.
Данное вознаграждение распространяется на авиабилеты, выписанные в период с 15.10.12г. по 31.03.2013г. (включая обе даты)"
check { includes(country_iatas.first, 'RU') and not includes_only(city_iatas.last, "PRG KLV") }
discount "3.5%"
commission "6%/4%"

example 'cdgsvo'
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
example 'cdgsvo svocdg/ab'
agent    "9% от всех опубл. тарифов на рейсы OM (В договоре Interline не прописан.)"
important!
subagent "2,5% от опубл. тарифов на собств.рейсы OM"
interline :no, :unconfirmed
## discount "5%"
commission "9%/2.5%"

carrier "OS", "AUSTRIAN AIRLINES"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.2%'

example 'dmejfk/Q'
example 'dmejfk/Q jfkdme/lx/Q'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check { includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') }
subclasses "FADZPQVWSTLK"
interline :no, :yes
our_markup "0"
discount '6.5%'
ticketing_method "downtown"
commission "10%/8%"

example 'dmejfk'
example 'dmejfk jfkdme/lx/L'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check { includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') }
#subclasses "YBMUH"
interline :no, :yes
our_markup "0"
discount '1%'
ticketing_method "downtown"
commission "5%/3%"

example 'dmebcn'
example 'bcndme dmebcn/lh'
agent    "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS.
(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
check {includes(country_iatas, 'ES FR IT CZ PT NL CH') }
interline :no, :yes
our_markup "20"
## discount '5%'
commission "1/0.05"

example 'svooko'
example 'svooko okosvo/ab'
agent    "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS.
(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
interline :no, :yes
our_markup "20"
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
example 'cdgsvo svocdg/ab'
agent    "1% от всех опубл. тарифов на рейсы OV (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы OV"
interline :no, :unconfirmed
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
discount "2.5%"
commission "5%/3.5%"

carrier "PS", "Ukraine International Airlines (ГЛОНАСС)"
########################################

example 'svocdg'
agent    "9% от опубл. тарифов на собств.рейсы PS"
subagent "9% от опубл. тарифов на собств.рейсы PS"
discount "8.5%"
commission "9%/9%"

example 'cdgsvo svocdg/ab'
agent "5% от опубл. тарифов на рейсы Interline c обязательным участком PS"
subagent "3% от опубл. тарифов на рейсы Interline c обязательным участком PS"
interline :yes
discount "2%"
commission "5%/3%"

example 'cdgsvo/ab'
strt_date "12.10.2012"
agent "0% от опубл. тарифов на рейсы Interline без участка PS"
subagent "0% от опубл. тарифов на рейсы Interline без участка PS"
interline :absent
commission "0%/0%"

carrier "QF", "QANTAS AIRWAYS\n(не BSP!!!)"
########################################
carrier_defaults :disabled => 'не bsp'

example 'svocdg'
agent    "7% от опубл. тарифов на рейсы QF (В договоре Interline не прописан.)"
subagent "4,9% от опубл. тарифов на рейсы QF"
interline :no, :unconfirmed
commission "7%/4.9%"

carrier "QR", "QATAR AIRWAYS"
########################################

example 'ledpek/business pekled/business'
strt_date "01.04.2012"
agent    "от опубл. тарифов, а также от опубл. IT гросс тарифов (искл.групповые тарифы) на собств.рейсы QR: 5% Бизнес класс"
subagent "3,5% от опубл. тарифов на собственные рейсы QR"
classes :business
discount "2%"
commission "5%/3.5%"

example 'ledpek/economy pekled/economy'
example 'ledpek/business pekled/economy'
strt_date "01.04.2012"
agent    "1% Эконом класса, а также при различной комбинации Бизнес/Эконом;" 
subagent "5 руб. с билета Эконом класса, а также при различной комбинации Бизнес/Эконом;"
commission "1%/5"

example 'svocdg cdgsvo/ab'
strt_date "01.04.2012"
agent    "1% на рейсы Interline (только при обязат. пролете первого сектора на рейсах QR)."
subagent "5 руб. с билета на рейсы Interline (только при обязат. пролете первого сектора на рейсах QR)."
interline :first
commission "1%/5"

example 'cdgsvo/ab svocdg'
no_commission

carrier "RB", "SYRIAN ARAB AIRLINES"
########################################

#example 'svocdg'
agent    "7% от всех опубл. тарифов на рейсы RB (В договоре Interline не прописан.)"
subagent "5% от опубл. тарифов на рейсы RB"
## discount "4%"
disabled "Катя сказала выключить, потому что война"
commission "7%/5%"

#example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
## discount "4%"
disabled "Катя сказала выключить, потому что война"
commission "7%/5%"

carrier "S4", "SATA INTERNACIONAL (РИНГ АВИА)"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от всех опубл. тарифов на собств.рейсы S4 (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы S4"
interline :no, :unconfirmed
commission "1%/0.5%"

carrier "SA", "South African Airways"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1% от опубл. тарифов на собств. рейсы. SA и рейсы Interline"
subagent "0,5% от опубл. тарифа на собств. рейсы SA и рейсы Interline"
interline :no, :yes
commission "1%/0.5%"

carrier "SK", "SAS"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.5%'

example 'svojfk'
example 'svojfk jfksvo/sk'
agent    "через DTT из России в США и наоборот - 12%"
subagent "через DTT из России в США и наоборот - 10%"
check {includes(country_iatas, 'US CA') }
subclasses "CDYSEHM"
interline :no, :yes
our_markup "0"
discount '8%'
ticketing_method "downtown"
commission "12%/10%"

example 'svojfk/Q'
example 'svojfk/Q jfksvo/sk/Q'
agent    "через DTT из России в США и наоборот - 8%"
subagent "через DTT из России в США и наоборот - 6%"
check {includes(country_iatas, 'US CA') }
#subclasses "JZBQVWKLT"
interline :no, :yes
our_markup "0"
discount '4%'
ticketing_method "downtown"
commission "8%/6%"

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent    "1 руб. с билета на рейсы SAS. (Билеты «Интерлайн» под кодом Авиакомпании могут быть выписаны только в случае существования опубл. тарифов и только при условии, если Авиакомпания выполняет хотя бы один рейс.)"
subagent "50 коп. с билета на рейсы SAS"
interline :no, :yes
our_markup "0.5%"
commission "1/0.5"

carrier "SN", "BRUSSELS AIRLINES"
########################################

carrier_defaults :consolidator => 0, :our_markup => '0.5%'

example 'dmejfk/Q jfkdme/f'
example 'dmejfk/Q jfkdme/lh/Q'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check {
  includes(country_iatas, 'RU UA PL RO') and includes_only(country_iatas.last, 'US') or
  includes(country_iatas, 'US') and includes_only(country_iatas.last, 'RU UA PL RO')
}
subclasses "FADZPQVWSTLK"
interline :no, :yes
our_markup "0"
discount '6%'
ticketing_method "downtown"
commission "10%/8%"

example 'dmejfk/y jfkdme/b'
example 'dmejfk jfkdme/lh/b'
agent    "через DTT из России в США и наоборот - 5%"
subagent "через DTT из России в США и наоборот - 3%"
check {
  includes(country_iatas, 'RU UA PL RO') and includes_only(country_iatas.last, 'US') or
  includes(country_iatas, 'US') and includes_only(country_iatas.last, 'RU UA PL RO')
}
subclasses "YBMUH"
interline :no, :yes
our_markup "0"
discount '1%'
ticketing_method "downtown"
commission "5%/3%"

#example 'dmence'
#agent    "через DTT - 5%"
#subagent "через DTT - 3%"
#interline :no
#our_markup "0"
#discount '1.5%'
#commission "5%/3%"

example 'svocdg'
example 'DMEBRU'
example 'BRULBA'
agent    "0,5% от опубл. тарифам на собств. рейсы SN;"
subagent "5 руб. с билета по опубл. тарифам на собств. рейсы SN;"
our_markup "60"
commission "0.5%/5"

example 'svocdg cdgsvo/ab'
agent    "0,5% от опубл. тарифам в случае применения совмещенного тарифа авиакомпаний;"
subagent "5 руб. с билета по опубл. тарифам в случае применения совмещенного тарифа авиакомпаний;"
interline :yes
our_markup "60"
commission "0.5%/5"

carrier "SQ", "SINGAPORE AIRLINES (Авиарепс)"
########################################

example 'svosin'
agent    "3% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
subagent "2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
# interline :no, :yes
check { includes(country_iatas.first, 'RU') }
discount "1.5%"
commission "3%/2%"

example 'svohou houmia'
example 'housvo'
agent    "6% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
subagent "4,2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
important!
# interline :no, :yes
check { (includes(country_iatas.first, 'RU') and includes(city_iatas, 'HOU')) or 
  (includes(city_iatas.first, 'HOU') and includes(country_iatas.last, 'RU')) }
discount "3.5%"
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
discount "1.5%"
commission '3%/2%'

carrier "SW", "AIR NAMIBIA (АВИАРЕПС)"
########################################

example 'svocdg'
agent    "7% от опубл. тарифов на собств. рейсы SW (В договоре Interline отдельно не прописан.)"
subagent "5% от опубл. тарифов на собств.рейсы SW"
interline :no, :unconfirmed
discount "3%"
commission "7%/5%"

carrier "TG", "THAI AIRWAYS"
########################################

example 'svobkk'
agent "С 01.02.2011г. 5% от всех опубл.и конфиденциальных тарифов на международные рейсы TG"
subagent "С 01.02.2011г. 3% от опубл. и конфиде.тарифов на международные рейсы TG"
international
discount "2.5%"
commission "5%/3%"

example 'bkkdmk'
agent "С 01.02.2011г. 0% от всех опубл. тарифов на внутренние рейсы TG"
subagent "С 01.02.2011г. 0% от опубл.тарифов на внутренние рейсы TG"
domestic
commission "0%/0%"

example 'svobkk/su bkkdmk'
agent "0% от тарифов на рейсы Interline. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
subagent "0% от опубл. тарифа на рейсы Interline с участком TG. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
interline :yes
commission "0%/0%"

carrier "TK", "TURKISH AIRLINES"
########################################

example "svoist/economy"
strt_date '15.10.2012'
expr_date '16.03.2013'
agent "10% от тарифа Эконом класса на рейсы TK с вылетом из РФ"
subagent "8% от тарифа Эконом класса на рейсы TK с вылетом из РФ"
classes :economy
check { includes(country_iatas.first, 'RU') }
important!
discount "7.5%"
commission "10%/8%"

example "svoist/business"
strt_date '15.10.2012'
expr_date '16.03.2013'
agent "17% от тарифа Бизнес класса на рейсы TK с вылетом из РФ"
subagent "15% от тарифа Бизнес класса на рейсы TK с вылетом из РФ"
classes :business
check { includes(country_iatas.first, 'RU') }
important!
discount "13.5%"
commission "17%/15%"

example 'istsvo svoist'
agent    "7% от полного опубл. тарифа IATA на рейсы TK;"
subagent "5% от тарифа экономического класса на рейсы TK;"
discount "4%"
commission "7%/5%"

example 'istank'
example 'istank/business'
agent    "5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
subagent "3,5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
important!
domestic
classes :business, :economy
discount "2.5%"
commission "5%/3.5%"

example 'svoist istsvo/ab'
agent    "Как обычная 7% (Билеты «Интерлайн» под кодом TK могут быть выписаны только в случае существования опубл. тарифов и только при условии, если TK выполняет первый рейс)"
subagent "Как обычная 5%"
interline :first
discount "4.5%"
commission "7%/5%"

carrier "TP", "TAP PORTUGAL"
########################################

example 'svocdg cdgsvo'
agent    "1% от опубл. тарифов на собств. рейсы TP и рейсы Interline"
subagent "0,5% от опубл. тарифа на собственные рейсы TP и рейсы Interline"
interline :no, :yes
## discount "0.3%"
commission "1%/0.5%"

carrier "UA", "UNITED AIRLINES (ГЛОНАСС)"
########################################

example 'dmejfk/Q'
example 'dmejfk/Q jfkdme/lh/Q'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check { includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') }
subclasses "FADZPQVWSTLK"
interline :no, :yes
our_markup "0"
discount '6.9%'
ticketing_method "downtown"
commission "10%/8%"

example 'dmejfk'
example 'dmejfk jfkdme/lh/L'
agent    "через DTT из России в США и наоборот - 10%"
subagent "через DTT из России в США и наоборот - 8%"
check { includes(country_iatas, 'RU UA PL RO') and includes(country_iatas, 'US') and not includes(country_iatas, 'CA') }
#subclasses "YBMUH"
interline :no, :yes
our_markup "0"
discount '1.8%'
ticketing_method "downtown"
commission "5%/3%"

#example 'SVOIAD/UA965/H'
#example 'SVOIAD/UA965/F'
#strt_date "03.02.2012"
#expr_date "31.08.2012"
#agent "С 03.02.12г. по 31.12.12г. 8% от опубл. тарифов на все классы бронирования на собств. рейсы UA с  обяз. наличием в маршруте трансатлантического рейса Москва-Вашингтон UA965 или Вашингтон-Москва UA964.Начало путешествия возможно как в России, так и за рубежом."
#subagent "С 03.02.12г. по 31.12.12г. 6% от опубл. тарифов на все классы бронирования
#на собств.рейсы UA с обяз. наличием в маршруте трансатлант. рейса Москва-Вашингтон UA	UA965 или Вашингтон-Москва UA964.Начало путешествия возможно как в России,
#так и за рубежом."
#important!
#check { includes(flights.every.full_flight_number, %W(UA965 UA964)) }
#discount "4.5%"
#commission "8%/6%"

example 'svocdg/K'
strt_date "03.02.2012"
expr_date "31.08.2012"
agent "1% от всех остальных опубл. тарифов на собственные рейсы UA"
subagent "0.5%  от всех остальных опубл. тарифов на собственные рейсы UA"
## discount "0.2%"
commission "1%/0.5%"

example 'yowjfk'
example 'yowdme dmeyow'
strt_date "01.09.2012"
agent "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде;"
agent "1% от всех опубл. тарифов на собств.рейсы UA из России в США с обязательным участием авиакомпании UA на трансатлантических перелетах из Европейских городов в города США."
subagent ""
check { includes_only(country_iatas.first, 'US CA') }
commission "0%/0%"

carrier "UL", "SRI LANKAN AIRLINES"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "1% от всех опубл. тарифов на собств. рейсы UL (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на собств.рейсы UL"
interline :no, :unconfirmed
## discount "0.3%"
commission "1%/0.5%"

carrier "UX", "Air Europa"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "5% от всех опубл. тарифов на рейсы UX (В договоре Interline отдельно не прописан.)"
subagent "3,5% от опубл. тарифов на собств. рейсы UX"
interline :no, :unconfirmed
discount "3%"
commission "5%/3.5%"

carrier "VN", "VIETNAM AIRLINES"
########################################

example 'svohan hansvo'
expr_date "31.08.2012"
agent    "По 31.08.12г. 5% от опубл. тарифов на междунар.рейсах VN;"
subagent "По 31.08.12г. 2% от опубл. тарифов на междунар.рейсах VN;"
international
discount "1%"
commission "5%/2%"

#example 'svohan hansvo'
strt_date "01.09.2012"
agent    "C 01.09.12г. 3% от опубл. тарифов на междунар.рейсах VN;"
subagent "2% от опубл. тарифов на междунар.рейсах VN;"
international
discount "1%"
commission "3%/2%"

example 'hansgn'
expr_date "31.08.2012"
agent    "5% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent "3,5% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
discount "3%"
commission "5%/3.5%"

#example 'hansgn'
strt_date "01.09.2012"
agent    "3% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent "2% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
discount "0.8%"
commission "3%/2%"

example 'svohan hansvo/su'
expr_date "31.08.2012"
agent    "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
commission "0%/0%"

carrier "VS", "Virgin Atlantic Airways Limited (ГЛОНАСС)"
########################################

example 'svocdg cdgsvo'
agent    "7% от опубл. тарифов на собств. рейсы VS"
subagent "5% от опубл. тарифов на собств.рейсы VS"
discount "4%"
commission "7%/5%"

example 'svolhr/ba lhrcce'
agent    "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :yes
# FIXME надо ли проверять трансатлантику?
check { includes(%W(UN BA SU), marketing_carrier_iatas.first) and includes(marketing_carrier_iatas.second, 'VS') }
discount "4%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
no_commission

carrier "VV", "AEROSVIT"
########################################

carrier_defaults our_markup: 0, :disabled => "Going to bankrupt"

example 'leddok'
example 'ledcdg'
strt_date "01.08.2012"
agent "9% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV"
subagent "8,5% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории РФ до любого п.п. VV."
check { includes(country_iatas.first, 'RU') and not includes(city_iatas.first, 'MOW') and not includes(city_iatas.last, 'IEV') }
discount "7%"
no_commission "9%/8.5%"

example 'ledkbp kbptlv'
example 'ledkbp kbpcdg'
example 'ledkbp kbptbs'
strt_date "21.03.2012"
expr_date "01.04.2013"
agent "10% от тарифа при продаже перевозок с началом перевозки от Санкт-Петербурга до п.п. VV на территорию третьих стран трансфером через Киев;"
subagent "9,5% от тарифа при продаже перевозок с началом перевозки от Санкт- Петербурга до п.п. VV на территорию третьих стран трансфером через Киев;"
check { includes(city_iatas.first, 'LED') and includes(city_iatas, 'IEV') and not includes(country_iatas.last, 'UA') and not includes(country_iatas.last, 'RU') }
important!
discount "8%"
no_commission "10%/9.5%"

example 'svokbp/business kbpsvo/business'
strt_date "01.08.2012"
agent "9% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
classes :business
check { (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'IEV')) or (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'MOW') and includes(city_iatas, 'IEV')) }
discount "3%"
no_commission "5%/4.5%"

example 'svokbp kbpsvo'
strt_date "01.08.2012"
agent "7% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
subagent "4,5% от тарифа при продаже перевозок на рейсы Москва-Киев (MOW-IEV), Москва-Киев-Москва (MOW -IEV- MOW);"
check { (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'IEV')) or (includes(city_iatas.first, 'MOW') and includes(city_iatas.last, 'MOW') and includes(city_iatas, 'IEV')) }
discount "3%"
no_commission "5%/4.5%"

example 'kbpdok'
example 'kbptbs'
example 'tbstlv'
strt_date "21.03.2012"
agent "1% от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
subagent "5 рублей от тарифа при продаже перевозок с началом перевозки от п.п. VV на территории Украины или третьих стран;"
check { not includes(country_iatas.first, 'RU') }
our_markup "60"
no_commission "1%/5"

example 'kbpsvo/ab svokbp'
strt_date "21.03.2012"
agent "5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
subagent "4,5% от тарифа при продаже перевозок на рейсы Interline с участием VV;"
interline :yes
discount "3%"
no_commission "5%/4.5%"

example 'kbpsvo/ab svokbp/ab'
strt_date "21.03.2012"
agent "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
subagent "0% от тарифа при продаже перевозок на рейсы Interline без участия VV;"
interline :absent
no_commission "0%/0%"

example 'svosip'
example 'svoods'
check {includes(city_iatas, 'SIP ODS')}
interline :no, :yes, :absent
important!
no_commission "Катя просила выключить срочно от 14.06.12"

carrier "WY", "OMAN AIR"
########################################

example 'svocdg'
agent    "5% от опубл. тарифов на собств. рейсы WY (В договоре Interline не прописан.)"
subagent "3% от опубл. тарифа на собств.рейсы WY"
discount "1.5%"
commission "5%/3%"

example 'cdgsvo svocdg/ab'
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
commission "1%/0.5%"

carrier "XW", "SkyExpress Limited"
########################################
carrier_defaults :disabled => 'отозвали лицензию'

example 'svocdg'
strt_date "01.10.2011"
agent    "С 01.10.11г.  5 (пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании;"
subagent "С 11.04.11г. 5% от всех опубл. тарифов на собств. рейсы XW;"
interline :no
commission "5%/5%"

example 'svocdg cdgsvo/gw'
agent     "С 01.10.11г. 3 (три) % от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) - как с участием, так и без участия собственных рейсов SkyExpress Limited Company (ЗАО “Небесный Экспресс”) (XW/492);"
subagent "С 11.04.11г. 3% от всех опубл. тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) – с/без участия собств. рейсов XW;"
interline :yes
check { includes_only(marketing_carrier_iatas, %W[XW GW]) }
commission "3%/3%"

example 'svopee peesvo/xf'
agent "С 11.04.11г. 1 (Один) Рубль РФ от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) - как с участием, так и без участия"
subagent "С 11.04.11г. 5 коп с билета по опубл. тарифам на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) – с/без участия собств. рейсов XW."
interline :yes
check { includes_only(marketing_carrier_iatas, %W[XF GW]) }
commission "1/0.05"

carrier "YM", "MONTENEGRO AIRLINES"
########################################

example 'svocdg'
example 'cdgsvo svocdg/ab'
agent    "8% от всех опубл. тарифов на рейсы YM (В договоре Interline не прописан.)"
subagent "6% от всех опубл. тарифов на рейсы YM"
interline :no, :unconfirmed
discount "5.2%"
commission "8%/6%"

carrier "YO", "Heli air Monaco (РИНГ АВИА)"
########################################

example 'svocdg'
agent    "1 руб. с билета на все виды тарифов (В договоре Interline не прописан.)"
subagent "50 коп. с билета на рейсы YO"
interline :no, :unconfirmed
commission "1/0.5"

carrier "ZI", "AIGLE AZUR (РИНГ-АВИА)"
########################################

example 'svocdg/i'
agent    "11% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subagent "9% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subclasses "IDJC"
discount "7.5%"
commission "11%/9%"

example 'svocdg/k'
agent "7% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subagent "5% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subclasses "MKONXHBYSW"
discount "3.8%"
commission "7%/5%"

example 'svocdg/q'
agent "3% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subagent "2% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subclasses "TQUVL"
discount "1%"
commission "3%/2%"

example 'cdgsvo/un'
example 'cdgsvo svocdg/un'
agent "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
subagent "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
interline :yes
check { includes_only(marketing_carrier_iatas, 'UN  ZI') }
disabled "Система не дает интерлайн"
commission "0%/0%"

carrier "J2", "Azerbaijan Hava Yollari"
########################################
carrier_defaults :disabled => 'нет ETKT'

example 'svocdg'
agent    "1 рубль за 1 выписанный билет на стоке 771"
subagent "5 коп. с билета по опубл тарифам на собств. рейсы J2"
disabled "Выключил азеров, т.к. их нет в BSP"
commission "1/0.05"

carrier "AT", "ROYAL AIR MAROC"
########################################

example 'svocdg'
agent "5% от опубл. тарифов Эконом класса на собств. рейсы АТ"
subagent "3% от опубл. тарифов Эконом класса на собств. рейсы АТ"
classes :economy
discount "1.8%"
commission "5%/3%"

example 'svocdg/business'
agent "7% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
subagent "5% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
classes :business
discount "3.5%"
commission "7%/5%"

example 'svocdg cdgsvo/ab'
interline :yes, :absent
no_commission

carrier "NX", "AIR MACAU"
########################################

example 'svocdg'
agent "5 % от всех опубл. тарифов на собственные рейсы NX"
subagent "3% от всех опубл. тарифов на собственные рейсы NX"
## discount "2.5%"
commission "5%/3%"

carrier "U6", "ОАО Авиакомпания  УРАЛЬСКИЕ  АВИАЛИНИИ"
########################################

agent "7 (семь)%,  продажа международных перевозок по опуб.тар и продажа трансферных перевозок по сквозным тарифам и трансферных перевозок по сквозным тарифам, полученным путем end-on-end комбинации опубликованных тарифов перевозчиков;"
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
carrier_defaults :disabled => "Банкрот"

example 'svocdg'
agent "5% от опубл. тарифов на собств. рейсы авиакомпании."
subagent "3% от всех опубл. тарифов на собств. рейсы GW"
## discount "2.5%"
commission "5%/3%"

example 'svocdg cdgsvo/ab'
agent "3% от опубл. тарифов на рейсы Interline c обязательным участием GW. Выписка на рейсы Interline без участка GW запрещена."
subagent "1% от всех опубл. тарифов на собств. рейсы GW"
interline :yes
## discount "0.5%"
commission "3%/1%"

carrier "CQ", "Czech Connect Airlines"
########################################

example 'svocdg'
agent "6% от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent "4% от всех опубл. тарифов на собств. рейсы CQ"
interline :no, :unconfirmed
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
commission "5%/3%"

carrier "IZ", "Arkia"
########################################

example 'svocdg'
agent "7% от всех опубл. тарифов; (Interline отдельно не прописан)"
subagent "5% от всех опубл.тарифов на собств. рейсы IZ"
interline :no, :unconfirmed
discount "3.5%"
commission "7%/5%"

carrier "5L", "AEROSUR (РИНГ АВИА)"
########################################

example 'svocdg'
agent "1% от опубл. тарифов на собств. рейсы 5L"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы 5L"
interline :no, :unconfirmed
commission "1%/0.5%"

carrier "FJ", "AIR PACIFIC LIMITED (РИНГ АВИА)"
########################################

example 'TVUNAN/L NANVLI/Q' #между фиджи и фиджи
example 'suvakl aklsuv/ab'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на короткие расстояния,"
agent "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
subagent "3% от всех опубл.тарифов на собств. рейсы FJ для перевозки на короткие расстояния,"
subagent "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
check { includes_only(country_iatas, %W(FJ AU NZ KI MH FM NR PG WS SB TO TV VU CK AS PF GU NC NU NF MP PW)) }
interline :no, :yes
discount "1.5%"
commission "5%/3%"

example 'suvcdg'
example 'suvcdg cdgsuv/ab'
agent "7% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на дальние расстояния,"
agent "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
subagent "5% от всех опубл.тарифов на собств. рейсы FJ для перевозки на дальние расстояния,"
subagent "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
check { includes(country_iatas, 'FJ') }
interline :no, :yes
discount "3%"
commission "7%/5%"

carrier "RC", "ATLANTIC AIRWAYS (РИНГ АВИА)"
########################################

example 'svocdg'
example 'svocdg cdgsvo/ab'
agent "5% от всех опубл.тарифов на собств. рейсы авиакомпании. (Interline отдельно не прописан)"
subagent "3% от всех опубл. тарифов на собств. рейсы RC"
interline :no, :unconfirmed
discount "2%"
commission "5%/3%"

carrier "A3", "AEGEAN AIRLINES S.A"
########################################

example 'scocdg cdgsvo'
agent " 7% для тарифов Экономического класса"
subagent "Международные рейсы А3: 5% для тарифов Эконом класса"
international
discount "3%"
commission "7%/5%"

example 'svocdg/business cdgsvo/business'
agent "9% для тарифов Бизнес класса"
subagent "7% для тарифов Бизнес класса"
classes :business
important!
international
discount "5%"
commission "9%/7%"

example 'skgath athskg/business'
agent "Внутренние перелеты: 1% для тарифов Экономического и Бизнес классов"
subagent "5 руб. с билета для тарифов Эконом и Бизнес классов"
classes :economy, :business
domestic
commission "1%/5"

example 'svocdg cdgsvo/ab'
agent "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
commission "1/0"

carrier "BJ", "NOUVELAIR (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

carrier_defaults :disabled => 'предательски отменяют сегменты'

agent "6% от всех опубл. тарифов на рейсы BJ"
subagent "4% от всех опубликованных тарифов на рейсы BJ"
discount "2.5%"
commission "6%/4%"

carrier "MD", "AIR MADAGASCAR (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

example 'svocdg'
agent "1 (Один) % от всех опубл. тарифов на собств. рейсы авиакомпании MD"
subagent "0.5% с билета по опубл. тарифам на собств. рейсы MD"
interline :no, :unconfirmed
commission "1%/0.5%"

carrier "TN", "AIR TAHITI NUI (Только с момента авторизации! ПРОВЕРЯТЬ!)"
########################################

example 'svocdg'
agent "1 (Один) рубль от всех опубл. тарифов на собств.рейсы авиакомпании TN"
subagent "5 коп. с билета по опубл. тарифам на собств. рейсы TN"
interline :no, :unconfirmed
commission "1/0.05"

carrier "9U", "Air Moldova"
########################################

example 'dmekiv'
agent "5 (пять) % от всех опубликованных тарифов."
subagent "3% от опубл. тарифов на рейсы 9U"
discount "1.5%"
commission "5%/3%"

carrier "A9", "GEORGIAN AIRWAYS"
########################################

example 'tbsdme'
agent "8 (восемь) % от опубл. тарифа на собств. рейсы авиакомпании А9;"
subagent "6 % от опубл. тарифа на собств. рейсы А9;"
discount "3%"
commission "8%/6%"

example 'tbsdme dmetbs/ab'
agent "7 (семь)  % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании  А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение;"
subagent "5 % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение"
interline :yes
discount "2.5%"
commission "7%/5%"

example 'dmetbs/ab'
agent "5 (пять)   % от опубл. тарифа на рейсы Interline без участка А9."
subagent "3 % от опубл. тарифа на рейсы Interline без участка А9."
interline :absent
discount "1%"
commission "5%/3%"

carrier "5H", "Five Fourty Aviation Limited (Fly540)"
########################################

example "svocdg"
agent "5 (пять) % от опубл. тарифов на собств. рейсы 5H"
subagent "3% от опубл. тарифов на собств. рейсы 5H"
## discount "2.5%"
commission "5%/3%"

carrier "U9", "Aircompany Tatarstan"
########################################

example 'svocdg/business cdgsvo/business'
agent "9% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
subagent "7% от опубл. тарифов на собств. рейсы U9 Бизнес класса;"
classes :business
discount "6%"
commission "9%/7%"

example 'svocdg/economy svocdg/economy'
agent "7% от опубл. тарифов на собств. рейсы U9 Эконом класса;"
subagent "5% от опубл. тарифов на собств. рейсы U9 Эконом класса"
classes :economy
discount "4.5%"
commission "7%/5%"

example 'svocdg/ab cdgsvo'
agent "2% от всех опубл. тарифов на рейсы Interline;"
subagent "1% от всех опубл. тарифов на рейсы Interline."
interline :yes
commission "2%/1%"

agent "3% от всех опубл. тарифов на рейсы code-share."
subagent "1% от всех опубл. тарифов на рейсы code-share;"
not_implemented "не умеем определять code-share"
commission "3%/1%"

carrier "RJ", "Royal Jordanian Airline"
########################################

example 'svocdg cdgsvo'
agent "5 (пять) % от всех опубл. тарифов на собств. рейсы RJ"
subagent "3% от опубл. тарифов на собств. рейсы RJ"
discount "1.5%"
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
## discount "1.5%"
commission "3%/2%"

carrier "CM", "COPA AIRLINES"
########################################

example 'svocdg cdgsvo'
agent "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
commission "1%/5"

example 'svocdg/ab cdgsvo'
agent "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
interline :yes
commission "1%/5"

example 'svocdg/ab cdgsvo/ab'
not_implemented

carrier "R3", "Авиакомпания «Якутия»"
########################################

example 'svocdg cdgsvo'
agent "6 % от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
subagent "4% от всех опубл. тарифов на все собств.рейсы Авиакомпании;"
discount "2.5%"
commission "6%/4%"

example 'ykscdg/ab cdgyks'
agent "4 % от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами Авиакомпании."
subagent "3% от всех опубл. тарифов на все рейсы, выполняемые Интерлайн-партнерами"
interline :yes
discount "1.5%"
commission "4%/3%"

carrier "S3", "SANTA BARBARA AIRLINES"
########################################

example 'svocdg cdgsvo'
agent "1 (один) % от всех опубл. тарифов на собств. рейсы S3"
subagent "5 руб. от всех опубл. тарифов на собств. рейсы S3"
commission "1%/5"

carrier "UT", "UTAIR"
########################################
carrier_defaults :consolidator => 0, :ticketing_method => "downtown"

example 'svocdg cdgsvo'
agent "5% DTT"
subagent "3% DTT"
discount "2.8%"
commission "5%/3%"

carrier "S7", "S7 AIRLINES"
########################################
carrier_defaults :consolidator => 0, :ticketing_method => "downtown"

example 'svocdg cdgsvo'
agent "выписывать руками в даунтауне, пока не появилась прямая продажа"
subagent ""
our_markup 300
##disabled "до времени"
#discount "1.9%"
interline :no, :yes
commission "0%/0%"

carrier "GA", "GARUDA INDONESIA"
########################################

example 'jogsoq soqjog'
agent "5% (Пять) от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
subagent "3% от всех опубл. тарифов на собств.рейсы GA на местные перелёты;"
domestic
discount "2%"
commission "5%/3%"

example "jogjed"
example "jogruh"
agent "от всех опубл. тарифов на собств. рейсы GA на международные перелёты зависит от пункта отправления (см. таблицу ниже):
ИНДОНЕЗИЯ: 1 РУБ  - если пункт назначения JED/RUH"
subagent "ИНДОНЕЗИЯ: 5 коп. с билета если пункт назначения JED/RUH"
check { includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(JED RUH)) }
commission "1/0.05"

example "jogsvo"
agent "ИНДОНЕЗИЯ: 7% - если пункт назначения любой город, кроме JED/RUH"
subagent "ИНДОНЕЗИЯ: 5% от тарифа если пункт назначения любой город, кроме JED/RUH"
check { includes(country_iatas.first, 'ID') and not includes(city_iatas.last, %W(JED RUH)) }
discount "2%"
commission "7%/5%"

example "joghkg"
example "jogkul"
example "jogsin"
agent "1 РУБ - SIN, 1 РУБ - HKG, 1 РУБ - KUL"
subagent "5 коп. с билета - SIN 5 коп. с билета - HKG 5 коп. с билета - KUL"
check { includes(country_iatas.first, 'ID') and includes(city_iatas.last, %W(SIN KUL HKG)) }
important!
commission "1/0.05"

example "okojog"
agent "ЯПОНИЯ: 1 РУБ - все тарифы, кроме GA FLEX/PEX FARES"
subagent "ЯПОНИЯ: 5 коп. с билета - все тарифы, кроме GA FLEX/PEX FARES	-"
check { includes(country_iatas.first, 'JP') }
commission "1/0.05"

#example "okojog"
agent "ЯПОНИЯ: 7% - GA FLEX/PEX FARES"
subagent "ЯПОНИЯ: 5% - GA FLEX/PEX FARES"
check { includes(country_iatas.first, 'JP') }
disabled "no subagent... FLEX PEX?"
discount "4%"
commission "7%/5%"

example "okoams"
agent "1%  - AMS"
subagent "5 руб. с билета - AMS"
check { includes(country_iatas.first, 'JP') and includes(city_iatas.last, 'AMS') }
important!
commission "1%/5"

example "okoswp"
example "okomel"
example "okoper"
example "okorse"
agent "5%  - SWP, 5%  - MEL/PER/SYD"
subagent "3% -SWP 3% - MEL/PER/SYD"
check { includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SWP MEL PER SYD)) }
important!
commission "5%/3%"

example "okossn"
example "okojed"
example "okoruh"
example "okodxb"
agent "7% - SEL, 7% - JED/RUH, 7% - DXB"
subagent "5% - SEL 5% - JED/RUH 5% - DXB"
check { includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(SEL JED RUH DXB)) }
important!
discount "4%"
commission "7%/5%"

example "okobkk"
example "okopek"
example "okosha"
agent "9% - BKK, 9% - BJS/CAN/SHA"
subagent "7% - BKK 7% - BJS/CAN/SHA"
check { includes(country_iatas.first, 'JP') and includes(city_iatas.last, %W(BKK BJS CAN SHA)) }
important!
discount "5%"
commission "9%/7%"

carrier "W2", "FLEXFLIGHT"
########################################

example 'svocdg cdgsvo'
agent "1% от всех опубл. Тарифов"
subagent "5 руб. с билета от всех опубл. тарифов"
commission "1%/5"

carrier "AR", "AEROLINEAS ARGENTINAS (АВИАРЕПС)"
########################################

example 'svocdg cdgsvo'
agent "1% от всех опубл. Тарифов"
subagent "5 руб. с билета от всех опубл. тарифов"
commission "1%/5"

carrier "KR", "AIR BISHKEK"
########################################

agent "5 % от всех опубл. тарифов на собств. рейсы KR"
subagent "3% от всех опубл. тарифов на собств. рейсы KR"
discount "2%"
commission "5%/3%"

carrier "DT", "TAAG ANGOLA AIRLINES"
########################################

agent "1% от всех опубл. тарифов на собств. рейсы DT"
subagent "5 руб. от всех опубл. тарифов на собств. рейсы DT"
commission "1%/5"

carrier "OG", "Air Onix Airlines"
########################################

agent "5% от опубл. тарифов на рейсы OG"
subagent "3% от опубл. тарифов на рейсы OG"
discount "2.5%"
commission "5%/3%"

carrier "EN", "Air Dolomiti"
########################################

agent "1% от всех опубл. тарифов"
subagent "5 руб. от всех опубл. тарифов"
commission "1%/5"

end
