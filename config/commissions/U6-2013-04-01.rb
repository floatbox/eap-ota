carrier "U6", start_date: "2013-04-01"

example "svocdg/business cdgsvo/business"
agent "7% от суммы тарифов всех подклассов Бизнес класса обслуживания, полученной от продажи международных перевозок (дальнее зарубежье)"
subagent "5% от суммы тарифов всех подклассов Бизнес класса обсл., полученной от продажи международных перевозок (дальнее зарубежье);"
classes :business
international
discount "4%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svocdg cdgsvo"
agent "5% от суммы тарифов всех подклассов Эконом класса обслуживания, полученной от продажи международных перевозок (дальнее зарубежье)"
subagent "3% от суммы тарифов всех подклассов Эконом класса обсл., полученной от продажи международных перевозок (дальнее зарубежье)"
international
discount "2%"
ticketing_method "aviacenter"
commission "5%/3%"

example "svotbs"
example "tbsiev"
comment "Россия СНГ и Грузия"
agent "5% от тарифов перевозок по России, СНГ и Грузии всех подклассов и классов обслуживания (за исключением маршрутов Групп А и Б)."
subagent "3% от тарифов перевозок по СНГ и Грузии всех подклассов и классов обслуживания (за искл. маршрутов Групп А и Б)"
important!
discount "2%"
ticketing_method "aviacenter"
check %{ includes_only(country_iatas, 'RU AZ AM BY KZ KG MD TJ TM UZ UA GE') }
commission "5%/3%"

example "svocdg/ab cdgsvo"
comment "интерлайны"
agent "3% от примененных тарифов на сегментах перевозки рейсов интерлайн-партнеров U6 ( наличие участка U6 в билете обязательно)"
subagent "1% от примененных тарифов на рейсы интерлайн-партнеров U6 (наличие участка U6 в билете обязательно)"
interline :yes
discount "0.5%"
ticketing_method "aviacenter"
check %{ not includes(operating_carrier_iatas, 'NN S7') }
commission "3%/1%"

example "svocdg/s7 cdgsvo"
comment "интерлайны"
agent "10 рублей за каждый участок перевозки, если в перевозке участвуют S7 и NN."
subagent "10 рублей за каждый участок перевозки, если в перевозке участвуют S7 и NN."
interline :yes
ticketing_method "aviacenter"
check %{ includes(operating_carrier_iatas, 'NN S7') }
commission "10/10"

example "svocdg/ab cdgsvo/ab"
comment "пункт 3"
agent "1 (один) рубль продажа перевозок на рейсы интерлайн-партнеров U6 без участков U6"
subagent "5 коп. продажа перевозок на рейсы интерлайн-партнеров U6 без участков U6"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0.05"

comment "загадочная хрень"
agent "1 (один) рубль за каждый выписанный авиабилет по конфиденциальным IT тарифам."
subagent "5 (пять) руб. за каждый выписанный авиабилет по конфиденциальным IT тарифам."
ticketing_method "aviacenter"
no_commission

example "ledllk"
example "svokzn"
example "kuflbd"
example "krrovb"
comment "группа А "
agent "ГРУППА А:"
agent "в размере 0,1%:"
agent "*от суммы тарифов (опубликованных в АСБ) по маршрутам:"
agent "*за каждый взятый с пассажира штраф при оформлении возврата или обмена авиабилетов с взиманием штрафных санкций;"
subagent "c 01.04.2013 г. 50 коп с билета по маршрутам:"
routes "MOW-KGD,KZN,UFA,LED,KUF,GOJ,KRR,AER,AAQ,GBB,BAK,GDZ,KVD,LLK,SIP,MRV/OW,RT", "SVX-AER,KZN,SIP,KUF,YKS,HTA,AAQ,UFA,GDZ,EVN,KHV,VVO,KRR,KJZ,PKC,BAK,TBS/OW,RT", "LED-LWN,LLK,VVO,IKT,KHV,YKS/OW,RT", "KUF-DYU/OW,RT", "KUF-AAQ/OW,RT", "KUF-AER/OW,RT", "KUF-LBD/OW,RT", "CEK-GOJ,TAS/OW,RT", "PEE-DYU,LBD/OW,RT", "UFA-LBD,DYU/OW,RT", "KJA-IKT,MRV/OW,RT", "MRV-AER/OW,RT", "SIP-GOJ/OW,RT", "EVN-GOJ,KUF/OW,RT", "KRR-VVO,OVB/OW,RT", "GOJ-TAS,SIP,NMA/OW,RT", "IKT-PKC/OW,RT"
important!
consolidator "2%"
ticketing_method "aviacenter"
commission "0.1%/0.5"

example "svotiv"
example "tivsvo"
example "svotiv tivsvo"
agent "0.1% Москва-Тиват; Тиват-Москва; Москва-Тиват-Москва; Тиват-Москва-Тиват;"
subagent "0.5 Москва-Тиват; Тиват-Москва; Москва-Тиват-Москва; Тиват-Москва-Тиват;"
routes "MOW-TIV/ALL"
important!
consolidator "2%"
ticketing_method "aviacenter"
commission "0.1%/0.5"

example "svohta"
comment "группа Б SPECIAL FOR CHITA"
agent "ГРУППА Б: 3 (три) % от тарифа по всем подклассам по маршрутам: Москва-Чита; Чита-Москва; Москва-Чита-Москва; Чита-Москва-Чита;"
subagent "1 (Один) % от тарифа по всем подклассам по маршрутам: Москва-Чита; Чита-Москва; Москва-Чита-Москва; Чита-Москва-Чита;"
routes "MOW-HTA/ALL"
important!
discount "0.5%"
ticketing_method "aviacenter"
commission "3%/1%"

