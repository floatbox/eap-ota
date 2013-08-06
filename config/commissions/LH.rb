carrier "LH"

rule 1 do
example "svojfk/y"
example "svojfk/y jfksvo/m"
agent_comment "по классам Y, B, M, U, H у них комиссия 5%"
subagent_comment "3%"
subclasses "YBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
discount "3%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
agent "5%"
subagent "3%"
end

rule 2 do
example "svojfk/q"
example "svojfk/q jfksvo/k"
example "svojfk/q jfksvo/m"
agent_comment "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent_comment "6%"
subclasses "QVWSTLKYBMUH"
routes "TR,AE,BH,IL,KW,QA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
discount "6%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
agent "8%"
subagent "6%"
end

rule 3 do
example "svojfk/f"
example "svojfk/a jfksvo/z"
example "svojfk/q jfksvo/f"
agent_comment "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent_comment "8%"
subclasses "FADZPQVWSTLKYBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
discount "8%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
agent "10%"
subagent "8%"
end

rule 4 do
example "dmebcn"
example "bcndme dmebcn/OS"
agent_comment "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent_comment "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
interline :no, :yes
routes "...ES,FR,IT,CZ,PT,NL,CH..."
discount "1.5%"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

rule 5 do
example "svooko"
example "svooko okosvo/ab"
example "dmejfk jfkdme/US"
agent_comment "1 руб. с билета по опубл. тарифам на собств. рейсы LH и рейсы Interline с участком LH. (Билеты Interline под кодом LH могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LH выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа. Исключение составляют рейсы авиакомпаний-партнёров: LX, EW, CL, IQ, C3 и 4U (Germanwings), а также сегменты авиакомпаний STAR Alliance в случае оформления билетов по тарифам STAR Round the World и Star Airpass Fares)"
subagent_comment "5 коп. с билета по опубл. тарифам на собственные рейсы LH и рейсы Interline с участком LH."
interline :no, :yes
discount "1.5%"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

rule 6 do
example "svocdg/LX"
example "svocdg/EW"
example "svocdg/CL"
example "svocdg/IQ"
example "svocdg/C3"
agent_comment "1 руб. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
subagent_comment "5 коп. с билета на рейсы 4U, LX, EW, CL, IQ, C3 на бланках LH (подразделение)"
interline :absent
discount "1.5%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, %W[LX EW CL IQ C3]) }
agent "1"
subagent "0.05"
end

rule 7 do
example "svocdg/ab"
no_commission
end

