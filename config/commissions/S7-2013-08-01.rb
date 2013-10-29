carrier "S7", start_date: "2013-08-01"

rule 1 do
ticketing_method "aviacenter"
agent "0.1%"
subagent "0.05"
consolidator "2%"
agent_comment "при продаже перевозок по коду бронирования W, оформленных на ПД на рейсы Перевозчика, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), вознаграждение составит:  0,1%(0,05р+2% сбор АЦ) от тарифа. "
interline :no, :yes
check %{ includes(booking_classes, "W") }
end

rule 2 do
ticketing_method "direct"
agent "0.1%"
subagent "0.1%"
discount "3.6%"
agent_comment "При продаже перевозок между г. Москва и г. Горно-Алтайск,г. Горно-Алтайск и"
agent_comment "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Варна,г. Варна и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Чита,г. Чита и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Анапа,г. Анапа и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Улан-Удэ,г. Улан-Удэ и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Южно-Сахалинск,г. Южно-Сахалинск и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Пекин,г. Пекин и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Алматы,г. Алматы и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Братск,г. Братск и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Иркутск и г. Магадан,г. Магадан и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Иркутск,г. Иркутск и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Омск и г. Пекин,г. Пекин и г. Омск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Улан-Удэ и г. Пекин,г. Пекин и г. Улан-Удэ, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Иркутск и г. Пекин,г. Пекин и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Бургас,г. Бургас и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Аликанте,г. Аликанте и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Пальма-де-Мальорка ,г. Пальма-де-Мальорка  и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Чита,г. Чита и г. Москва (C7-117/118), включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Симферополь,г. Симферополь и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Сплит,г. Сплит и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Пула,г. Пула и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Бангкок,г. Бангкок и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Новосибирск и г. Пхукет,г. Пхукет и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Иркутск и г. Банкок,г. Банкок и"
agent_comment "г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Красноярск и г. Банкок,г. Банкок и"
agent_comment "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Хабаровск и г. Банкок,г. Банкок и"
agent_comment "г. Хабаровск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Тиват,г. Тиват и"
agent_comment "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Симферополь,г. Симферополь и"
agent_comment "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Сочи,г. Сочи и"
agent_comment "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "При продаже перевозок между г. Москва и г. Анапа,г. Анапа и"
agent_comment "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Новосибирск и г. Прага, г. Прага и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика, исключая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет: 0,1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Москва и г. Лондон, г. Лондон и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика (Перевозчик - маркетинговый партнер), вознаграждение составляет: 0,1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Москва и г. Лиссабон, г. Лиссабон и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика (Перевозчик - маркетинговый партнер), вознаграждение составляет: 0,1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Москва и г. Абу-Даби, г. Абу-Даби и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика (Перевозчик - маркетинговый партнер), вознаграждение составляет: 0,1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Москва и г. Амман, г. Амман и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика (Перевозчик - маркетинговый партнер), вознаграждение составляет: 0,1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Москва и г. Тель-Авиа, г. Тель-Авив и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика (Перевозчик - маркетинговый партнер), вознаграждение составляет: 0,1%"
agent_comment "С 01.08.13г. При продаже перевозок между г. Владивовсток и г. Сеул, г. Сеул и г. Владивосток, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), офомленных на ПД на рейсы Перевозчика (Перевозчик - маркетинговый партнер), вознаграждение составляет: 0,1%"
check %{
  (includes(city_iatas, 'MOW') and includes(city_iatas, 'RGK VAR BTK BOJ SPU PUY TIV SIP AER AER AAQ ALC PMI HTA LON LIS AUH AMM TLV')) or
  (includes(city_iatas, 'OVB') and includes(city_iatas, 'HTA AAQ UUD UUS BJS HKG ALA BKK HKT SIP PRG')) or
  (includes(city_iatas, 'IKT') and includes(city_iatas, 'GDX OVB BJS BKK')) or
  (includes(city_iatas, 'OMS UUD') and includes(city_iatas, 'BJS')) or
  (includes(city_iatas, 'KJA KHV') and includes(city_iatas, 'BKK')) or
  (includes(city_iatas, 'VVO') and includes(city_iatas, 'SEL'))
}
example "svorgk"
example "rgksvo"
example "svorgk rgksvo"
example "ovbsvo svorgk"
example "ovbhta"
example "htaovb"
example "svoovb ovbhta"
example "ovbaaq"
example "aaqovb"
example "svoaaq aaqovb"
example "svovar"
example "varsvo"
example "svovar varsvo"
example "ovbuud"
example "uudovb"
example "svouud uudovb"
example "ovbuus"
example "uusovb"
example "svouus uusovb"
example "ovbpek"
example "pekovb"
example "svopek pekovb"
example "ovbhkg"
example "hkgovb"
example "svohkg hkgovb"
example "ovbala"
example "alaovb"
example "svoala alaovb"
example "svobtk"
example "btksvo"
example "ledbtk btksvo"
example "iktgdx"
example "gdxikt"
example "ledikt iktgdx"
example "ovbikt"
example "iktovb"
example "ledikt iktovb"
example "omspek"
example "pekoms"
example "ledoms omspek"
example "uudpek"
example "pekuud"
example "leduud uudpek"
example "iktpek"
example "pekikt"
example "ledikt iktpek"
example "svoboj"
example "bojsvo"
example "ledsvo svoboj"
example "svoalc"
example "alcsvo"
example "ledsvo svoalc"
example "svopmi"
example "pmisvo"
example "ledsvo svopmi"
example "svohta"
example "htasvo"
example "ledsvo svohta"
example "sipovb"
example "ovbsip"
example "ledsip sipovb"
example "svospu"
example "spusvo"
example "ledsvo svospu"
example "svopuy"
example "puysvo"
example "ledsvo svopuy"
example "ovbbkk"
example "bkkovb"
example "ovbbkk ovbbkk"
example "ovbhkt"
example "hktovb"
example "ovbhkt ovbhkt"
example "ovbbkk"
example "bkkovb"
example "ovbbkk bkkovb"
example "kjabkk"
example "bkkkja"
example "kjabkk bkkkja"
example "khvbkk"
example "bkkkhv"
example "khvbkk bkkkhv"
example "svotiv"
example "tivsvo"
example "svotiv tivsvo"
example "svosip"
example "sipsvo"
example "svosip sipsvo"
example "svoaer"
example "aersvo"
example "svoaer aersvo"
example "svoaaq"
example "aaqsvo"
example "svoaaq aaqsvo"
example "ovbprg"
example "svolgw"
example "svoauh"
example "svoamm"
example "svotlv"
example "svotlv tlvsvo"
example "vvossn"
end

rule 3 do
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
discount "2%"
agent_comment "При продаже перевозок на международные воздушные линии, включая комбинированную перевозку на внутренние воздушные линии и международные воздушные линии и комбинированную перевозку с несколькими участками международных воздушных линий, на которых установлен единый сквозной тариф (системный трансфер), оформленных на ПД на рейсы Перевозчика,включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет: 3%"
agent_comment "При продаже перевозок на внутренние воздушные линии, оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет: 3%"
subagent_comment "субагентская 1%"
interline :no, :yes
example "vvossn ssnvvo/ab"
example "ovbprg/ab prgovb"
example "svolgw/ab lgwsvo"
example "svoauh/ab auhsvo"
example "svoamm/ab ammsvo"
end

rule 4 do
no_commission "выключил подкласс A"
important!
interline :no, :yes
check %{ includes(booking_classes, "A") }
example "svocdg/a"
example "svocdg cdgsvo/a"
example "svocdg/ab/a cdgsvo"
end

