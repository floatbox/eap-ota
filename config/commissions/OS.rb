carrier "OS"

example "svojfk/f"
example "svojfk/a jfksvo/z"
agent "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent "8%"
subclasses "FADZP"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
discount "8%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
commission "10%/8%"

example "svojfk/q"
example "svojfk/q jfksvo/k"
agent "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent "6%"
subclasses "QVWSTLK"
routes "TR,AE,BH,IL,KW,QA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
discount "6%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
commission "8%/6%"

example "svojfk/y"
example "svojfk/y jfksvo/m"
agent "по классам Y, B, M, U, H у них комиссия 5%"
subagent "3%"
subclasses "YBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
discount "3%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
commission "5%/3%"

example "dmebcn"
example "bcndme dmebcn/lh"
agent "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
agent "(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
interline :no, :yes
routes "...ES,FR,IT,CZ,PT,NL,CH..."
discount "1.5%"
our_markup "10"
ticketing_method "aviacenter"
commission "1/0.05"

example "svooko"
example "svooko okosvo/ab"
agent "1 руб. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
agent "(Билеты Interline под кодом OS могут быть выписаны только в случае существования опубликованных тарифов и только при условии, что OS выполняет как минимум один рейс. В противном случае по билету должна быть сделана доплата до полного опублик. IATA тарифа)"
subagent "5 коп. с билета по опубл. тарифам на собств.рейсы OS и рейсы Interline с участком OS."
interline :no, :yes
discount "1.5%"
ticketing_method "aviacenter"
commission "1/0.05"

example "cdgsvo/ab"
no_commission

