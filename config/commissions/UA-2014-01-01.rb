carrier "UA", start_date: "2014-01-01"

rule 1 do
example "jfklax"
comment "внутренние"
agent_comment "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде"
domestic
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 2 do
example "jfksvo"
example "jfksvo svojfk"
example "yowjfk"
example "yowsvo"
comment "Сша/Канада, Американский континент"
agent_comment "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде;"
routes "US,CA..."
international
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 3 do
example "svojfk/f"
example "svojfk/a jfksvo/z"
agent_comment "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent_comment "8%"
subclasses "FADZP"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
international
discount "4%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP10"
agent "10%"
subagent "8%"
end

rule 4 do
example "svojfk/q"
example "svojfk/q jfksvo/k"
agent_comment "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent_comment "6%"
subclasses "QVWSTLK"
routes "TR,AE,BH,IL,KW,QA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
international
discount "3%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP8"
agent "8%"
subagent "6%"
end

rule 5 do
example "svojfk/y"
example "svojfk/y jfksvo/m"
agent_comment "по классам Y, B, M, U, H у них комиссия 5%"
subagent_comment "3%"
subclasses "YBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
international
discount "1.5%"
ticketing_method "downtown"
tour_code "815ZU"
designator "PP5"
agent "5%"
subagent "3%"
end

