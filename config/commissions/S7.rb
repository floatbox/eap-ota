carrier "S7"

example "svocdg/w cdgsvo/w"
comment "dtt по невыгодным условиям прямой выписки, w-класс"
agent "При продаже перевозок по коду бронирования W, оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0,1%"
subagent "0.1%"
interline :no_codeshare
subclasses "W"
ticketing_method "downtown"
disabled "Пока выключен"
commission "5%/3.5%"

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
comment "Огромная гео-вырезка без код-шера"
comment "выключил routes из-за сквозных тарифов. нужны реальные примеры, чтобы понять применимость routes"
comment "routes MOW-RGK,VAR,BTK,BOJ,SPU,PUY,TIV,SIP,AER,AAQ,ALC,PMI,HTA/ALL OVB-HTA,AAQ,UUD,UUS,BJS,HKG,ALA,BKK,HKT,SIP,IKT/ALL IKT-GDX,OVB,BJS,BKK/ALL OMS,UUD-BJS/ALL KJA,KHV-BKK/ALL"
agent "При продаже перевозок между г. Москва и г. Горно-Алтайск,г. Горно-Алтайск и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Варна,г. Варна и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Чита,г. Чита и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Анапа,г. Анапа и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Улан-Удэ,г. Улан-Удэ и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Южно-Сахалинск,г. Южно-Сахалинск и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пекин,г. Пекин и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Алматы,г. Алматы и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Братск,г. Братск и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Магадан,г. Магадан и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Иркутск,г. Иркутск и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Омск и г. Пекин,г. Пекин и г. Омск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Улан-Удэ и г. Пекин,г. Пекин и г. Улан-Удэ, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Пекин,г. Пекин и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Бургас,г. Бургас и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Аликанте,г. Аликанте и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пальма-де-Мальорка ,г. Пальма-де-Мальорка  и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Чита,г. Чита и г. Москва (C7-117/118), включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Симферополь,г. Симферополь и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сплит,г. Сплит и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пула,г. Пула и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Бангкок,г. Бангкок и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пхукет,г. Пхукет и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Банкок,г. Банкок и"
agent "г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Красноярск и г. Банкок,г. Банкок и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Хабаровск и г. Банкок,г. Банкок и"
agent "г. Хабаровск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Тиват,г. Тиват и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Симферополь,г. Симферополь и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сочи,г. Сочи и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Анапа,г. Анапа и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
interline :no_codeshare
ticketing_method "downtown"
check %{
  (includes(city_iatas, 'MOW') and includes(city_iatas, 'RGK VAR BTK BOJ SPU PUY TIV SIP AER AER AAQ ALC PMI HTA')) or
  (includes(city_iatas, 'OVB') and includes(city_iatas, 'HTA AAQ UUD UUS BJS HKG ALA BKK HKT SIP')) or
  (includes(city_iatas, 'IKT') and includes(city_iatas, 'GDX OVB BJS BKK')) or
  (includes(city_iatas, 'OMS UUD') and includes(city_iatas, 'BJS')) or
  (includes(city_iatas, 'KJA KHV') and includes(city_iatas, 'BKK'))
}
commission "5%/3.5%"

example "svocdg/w/ab:s7 cdgsvo/w"
agent "При продаже перевозок по коду бронирования W, оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0,1%"
subagent "0.1%"
subclasses "W"
ticketing_method "aviacenter"
commission "0.1%/0.1%"

example "svorgk/ab:s7"
example "rgksvo/ab:s7"
example "svorgk/ab:s7 rgksvo"
example "ovbsvo svorgk/ab:s7"
example "ovbhta/ab:s7"
example "htaovb/ab:s7"
example "svoovb/ab:s7 ovbhta"
example "ovbaaq/ab:s7"
example "aaqovb/ab:s7"
example "svoaaq aaqovb/ab:s7"
example "svovar/ab:s7"
example "varsvo/ab:s7"
example "svovar varsvo/ab:s7"
example "ovbuud/ab:s7"
example "uudovb/ab:s7"
example "svouud/ab:s7 uudovb"
example "ovbuus/ab:s7"
example "uusovb/ab:s7"
example "svouus uusovb/ab:s7"
example "ovbpek/ab:s7"
example "pekovb/ab:s7"
example "svopek pekovb/ab:s7"
example "ovbhkg/ab:s7"
example "hkgovb/ab:s7"
example "svohkg hkgovb/ab:s7"
example "ovbala/ab:s7"
example "alaovb/ab:s7"
example "svoala alaovb/ab:s7"
example "svobtk/ab:s7"
example "btksvo/ab:s7"
example "ledbtk btksvo/ab:s7"
example "iktgdx/ab:s7"
example "gdxikt/ab:s7"
example "ledikt iktgdx/ab:s7"
example "ovbikt/ab:s7"
example "iktovb/ab:s7"
example "ledikt iktovb/ab:s7"
example "omspek/ab:s7"
example "pekoms/ab:s7"
example "ledoms omspek/ab:s7"
example "uudpek/ab:s7"
example "pekuud/ab:s7"
example "leduud uudpek/ab:s7"
example "iktpek/ab:s7"
example "pekikt/ab:s7"
example "ledikt iktpek/ab:s7"
example "svoboj/ab:s7"
example "bojsvo/ab:s7"
example "ledsvo svoboj/ab:s7"
example "svoalc/ab:s7"
example "alcsvo/ab:s7"
example "ledsvo/ab:s7 svoalc"
example "svopmi/ab:s7"
example "pmisvo/ab:s7"
example "ledsvo svopmi/ab:s7"
example "svohta/ab:s7"
example "htasvo/ab:s7"
example "ledsvo svohta/ab:s7"
example "sipovb/ab:s7"
example "ovbsip/ab:s7"
example "ledsip sipovb/ab:s7"
example "svospu/ab:s7"
example "spusvo/ab:s7"
example "ledsvo svospu/ab:s7"
example "svopuy/ab:s7"
example "puysvo/ab:s7"
example "ledsvo svopuy/ab:s7"
example "ovbbkk/ab:s7"
example "bkkovb/ab:s7"
example "ovbbkk ovbbkk/ab:s7"
example "ovbhkt/ab:s7"
example "hktovb/ab:s7"
example "ovbhkt ovbhkt/ab:s7"
example "ovbbkk/ab:s7"
example "bkkovb/ab:s7"
example "ovbbkk bkkovb/ab:s7"
example "kjabkk/ab:s7"
example "bkkkja/ab:s7"
example "kjabkk/ab:s7 bkkkja"
example "khvbkk/ab:s7"
example "bkkkhv/ab:s7"
example "khvbkk bkkkhv/ab:s7"
example "svotiv/ab:s7"
example "tivsvo/ab:s7"
example "svotiv tivsvo/ab:s7"
example "svosip/ab:s7"
example "sipsvo/ab:s7"
example "svosip sipsvo/ab:s7"
example "svoaer/ab:s7"
example "aersvo/ab:s7"
example "svoaer aersvo/ab:s7"
example "svoaaq/ab:s7"
example "aaqsvo/ab:s7"
example "svoaaq aaqsvo/ab:s7"
comment "выключил routes из-за сквозных тарифов. нужны реальные примеры, чтобы понять применимость routes"
comment "routes MOW-RGK,VAR,BTK,BOJ,SPU,PUY,TIV,SIP,AER,AAQ,ALC,PMI,HTA/ALL OVB-HTA,AAQ,UUD,UUS,BJS,HKG,ALA,BKK,HKT,SIP,IKT/ALL IKT-GDX,OVB,BJS,BKK/ALL MS,UUD-BJS/ALL KJA,KHV-BKK/ALL"
agent "При продаже перевозок между г. Москва и г. Горно-Алтайск,г. Горно-Алтайск и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Варна,г. Варна и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Чита,г. Чита и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Анапа,г. Анапа и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Улан-Удэ,г. Улан-Удэ и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Южно-Сахалинск,г. Южно-Сахалинск и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пекин,г. Пекин и г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Алматы,г. Алматы и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Братск,г. Братск и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Магадан,г. Магадан и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Иркутск,г. Иркутск и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Омск и г. Пекин,г. Пекин и г. Омск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Улан-Удэ и г. Пекин,г. Пекин и г. Улан-Удэ, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Пекин,г. Пекин и г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Бургас,г. Бургас и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Аликанте,г. Аликанте и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пальма-де-Мальорка ,г. Пальма-де-Мальорка  и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Чита,г. Чита и г. Москва (C7-117/118), включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Симферополь,г. Симферополь и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сплит,г. Сплит и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Пула,г. Пула и г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Бангкок,г. Бангкок и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Новосибирск и г. Пхукет,г. Пхукет и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Иркутск и г. Банкок,г. Банкок и"
agent "г. Иркутск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Красноярск и г. Банкок,г. Банкок и"
agent "г. Новосибирск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Хабаровск и г. Банкок,г. Банкок и"
agent "г. Хабаровск, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Тиват,г. Тиват и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Симферополь,г. Симферополь и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Сочи,г. Сочи и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
agent "При продаже перевозок между г. Москва и г. Анапа,г. Анапа и"
agent "г. Москва, включая данную перевозку в комбинации с другими участками в составе трансферной перевозки по единому сквозному тарифу (системный трансфер), оформленных на ПД на рейсы Перевозчика, включая рейсы по соглашению код-шер (4000-4999), вознаграждение составляет 0.1%"
ticketing_method "aviacenter"
check %{
  (includes(city_iatas, 'MOW') and includes(city_iatas, 'RGK VAR BTK BOJ SPU PUY TIV SIP AER AER AAQ ALC PMI HTA')) or
  (includes(city_iatas, 'OVB') and includes(city_iatas, 'HTA AAQ UUD UUS BJS HKG ALA BKK HKT SIP')) or
  (includes(city_iatas, 'IKT') and includes(city_iatas, 'GDX OVB BJS BKK')) or
  (includes(city_iatas, 'OMS UUD') and includes(city_iatas, 'BJS')) or
  (includes(city_iatas, 'KJA KHV') and includes(city_iatas, 'BKK'))
}
commission "0.1%/0.1%"

example "svocdg/ab cdgsvo"
example "ledcdg/fv:s7 cdgled"
agent "Открыть выписку S7 на билеты код-шеринг и интерлайн в офисе MOWR228FA."
agent "Агентская комиссия 3%"
subagent "Субагентская комиссия 3%"
interline :no, :yes
discount "1.5%"
ticketing_method "direct"
disabled "Выключили прямую выписку"
commission "3%/3%"

example "svojfk jfksvo"
comment "general dtt для горячей замены"
agent "1% dtt"
subagent "3.5% dtt"
interline :no_codeshare
discount "3.5%"
ticketing_method "downtown"
commission "1%/3.5%"

example "svocdg/ab cdgsvo"
example "ledcdg/fv:s7 cdgled"
agent "рейсы код-шеринг и интерлайн без комиссии c дополнительным сбором 400 руб за билет"
subagent "0%"
interline :no, :yes
our_markup "400"
ticketing_method "downtown"
commission "0%/0%"

