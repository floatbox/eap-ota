carrier "LX"

rule 1 do
ticketing_method "downtown"
agent "10%"
subagent "8%"
discount "12%"
tour_code "815ZU"
designator "PP10"
agent_comment "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent_comment "8%"
subclasses "FADZP"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
example "svojfk/f"
example "svojfk/a jfksvo/z"
end

rule 2 do
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "10%"
tour_code "815ZU"
designator "PP8"
agent_comment "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent_comment "6%"
subclasses "QVWSTLK"
routes "TR,AE,BH,IL,KW,QA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
example "svojfk/q"
example "svojfk/q jfksvo/k"
end

rule 3 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "7%"
tour_code "815ZU"
designator "PP5"
agent_comment "по классам Y, B, M, U, H у них комиссия 5%"
subagent_comment "3%"
subclasses "YBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/OW,RT"
example "svojfk/y"
example "svojfk/y jfksvo/m"
end

rule 4 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "4%"
agent_comment "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX."
agent_comment "(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent_comment "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
interline :no, :yes
routes "...ES,FR,IT,CZ,PT,NL,CH..."
example "dmebcn"
example "bcndme dmebcn/lh"
end

rule 5 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "4%"
agent_comment "1 руб. с билета по опубл. тарифам на собств. рейсы LX и рейсы Interline с уч. LX."
agent_comment "(Билеты Interline под кодом LX могут быть выписаны только в случае существования опубл. тарифов и только при условии, что LX выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent_comment "5 коп. с билета по опубл. тарифам на собств.рейсы LX и рейсы Interline с уч. LX."
interline :no, :yes
example "svooko okosvo/ab"
end

