carrier "LH", start_date: "2013-11-25"

rule 1 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "8.5%"
tour_code "815ZU"
designator "PP5"
agent_comment "по классам Y, B, M, U, H у них комиссия 5%"
subagent_comment "3%"
subclasses "YBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
example "svojfk/y"
example "svojfk/y jfksvo/m"
end

rule 2 do
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "11.5%"
tour_code "815ZU"
designator "PP8"
agent_comment "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent_comment "6%"
subclasses "QVWSTLKYBMUH"
routes "TR,AE,BH,IL,KW,QA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
example "svojfk/q"
example "svojfk/q jfksvo/k"
example "svojfk/q jfksvo/m"
end

rule 3 do
ticketing_method "downtown"
agent "10%"
subagent "8%"
discount "13.5%"
tour_code "815ZU"
designator "PP10"
agent_comment "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent_comment "8%"
subclasses "FADZPQVWSTLKYBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
example "svojfk/f"
example "svojfk/a jfksvo/z"
example "svojfk/q jfksvo/f"
end

rule 4 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "8.5%"
agent_comment "Период продаж – 25 ноября – 31 декабря 2013г."
agent_comment "Вылет – до 31 декабря 2013г."
agent_comment "Пункт выписки авиабилетов: Российская Федерация"
agent_comment "Пункт вылета: Российская Федерация"
agent_comment "Направления:"
agent_comment "Российская Федерация – Европа (за исключением прямых и стыковочных рейсов  MOW-BER/DUS/FRA/MUC/VIE/ZRH/GVA/BRU; LED-DUS/VIE/GVA/ZRH)"
agent_comment "Российская Федерация – Интерконтинентальные направления."
agent_comment "В рамках настоящего Соглашения Перевозчик предоставляет Агентству вознаграждени"
agent_comment "в размере 5% (3%) от тарифов Y,B,M,G,H,U,Q,V,W,E,T,S в эконом-классе при выписке авиабилета."
agent_comment "Комбинация с другими классами бронирования невозможна."
agent_comment "Указанное вознаграждение предоставляется по билетам, выпущенным на бланках авиакомпании Люфтганза (220) и выполняемым исключительно Люфтганзой."
agent_comment "Указанное вознаграждение предоставляется по билетам, выпущенным на бланках авиакомпании Люфтганза (220) и выполняемым исключительно Люфтганзой."
agent_comment "Вознаграждение не предоставляется по следующим тарифам: неопубликованные тарифы, корпоративные тарифы, групповые тарифы, студенческие и туроператорские тарифы."
agent_comment "Вознаграждение предоставляется в момент выписки авиабилета посредством внесения в бронирование элемента FM5 для Amadeus (в случае выписки билетов в других системах бронирования процедура взимания комиссии соответствует процедуре взимания стандартной комиссии 5% (3%))."
subagent_comment "3%"
subclasses "YBMGHUQVWETS"
check %{ includes(country_iatas.first, "RU") and flights.last.dept_date < Date.new(2013, 12, 31) and (not includes(city_iatas.first, "MOW") and not includes(city_iatas.second, "BER DUS FRA MUC VIE ZRH GVA BRU") or not includes(city_iatas.first, "LED") and not includes(city_iatas.second, "DUS VIE GVA ZRH")) and not includes(country_iatas, "US") }
example "svocdg"
end

rule 5 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "5.5%"
consolidator "2%"
agent_comment "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent_comment "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
interline :no, :yes
example "svooko okosvo/ab"
example "dmejfk jfkdme/US"
end

rule 6 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "5.5%"
consolidator "2%"
agent_comment "1 руб. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
subagent_comment "5 коп. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
interline :absent
check %{ includes_only(marketing_carrier_iatas, %W[LX EW CL IQ C3]) }
example "svocdg/LX"
example "svocdg/EW"
example "svocdg/CL"
example "svocdg/IQ"
example "svocdg/C3"
end

rule 7 do
no_commission
example "svocdg/ab"
end

