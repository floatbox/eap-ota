carrier "UA", start_date: "2013-06-20"

rule 1 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "2.5%"
consolidator "2%"
comment "внутренние"
agent_comment "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде"
domestic
example "jfklax"
end

rule 2 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "2.5%"
consolidator "2%"
comment "Сша/Канада, Американский континент"
agent_comment "0% от всех опубл. тарифов на собств.рейсы UA на внутренних маршрутах внутри Американского континента и международных маршрутах с началом путешествия в США или Канаде;"
routes "US,CA..."
international
example "jfksvo"
example "jfksvo svojfk"
example "yowjfk"
example "yowsvo"
end

rule 3 do
disabled "ведь по dtt продаем же"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "3.5%"
consolidator "2%"
agent_comment "5% (3%) (3%) на все опубл. тарифы Эконом класса во всех подклассах бронирования из России в США, Канаду и Латинскую Америку с перелетом из России в Европейские города авиакомпаниями, входящими в LH Group ( LH,LX,SN) , и трансатлантическим перелетом авиакомпанией United под кодом UA. Обратный перелет также должен быть строго в этой комбинации. (0% если начало путешествия на UA будет из Европы)."
agent_comment "Проездной документ должен быть оформлен единым билетом на стоке 016."
subagent_comment "3%"
classes :economy
check %{ includes_only(operating_carrier_iatas.first, 'LH LX SN') and includes(operating_carrier_iatas.second, 'UA') and includes(country_iatas.first, 'RU') }
example "svocdg/lh cdgjfk jfkcdg/lx cdgsvo"
end

rule 4 do
disabled "ведь по dtt продаем же"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "5.5%"
consolidator "2%"
agent_comment "7% (5%) (5%) в следующих подклассах бронирования: F/A/J/C/D/Z на все опубл. тарифы из России в США, Канаду и Латинскую Америку с перелетом из России в Европейские города авиакомпаниями, входящими в LH Group (LH,LX,SN) , и трансатлантическим перелетом авиакомпанией United под кодом UA. Обратный перелет также должен быть строго в этой комбинации. (0% если начало путешествия на UA будет из Европы)."
agent_comment "Проездной документ должен быть оформлен единым билетом на стоке 016."
subagent_comment "5%"
subclasses "FAJCDZ"
check %{ includes_only(operating_carrier_iatas.first, 'LH LX SN') and includes(operating_carrier_iatas.second, 'UA') and includes(country_iatas.first, 'RU') }
example "svocdg/lh/f cdgjfk/a jfkcdg/lx/c cdgsvo/z"
end

rule 5 do
ticketing_method "downtown"
agent "10%"
subagent "8%"
discount "8%"
tour_code "815ZU"
designator "PP10"
agent_comment "по классам F, A,D, Z, P у них осталась комиссия 10 %"
subagent_comment "8%"
subclasses "FADZP"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SD,SN,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
international
example "svojfk/f"
example "svojfk/a jfksvo/z"
end

rule 6 do
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "6%"
tour_code "815ZU"
designator "PP8"
agent_comment "по классам Q, V, W, S, T, L, K у них комиссия 8%"
subagent_comment "6%"
subclasses "QVWSTLK"
routes "TR,AE,BH,IL,KW,QA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
international
example "svojfk/q"
example "svojfk/q jfksvo/k"
end

rule 7 do
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "3%"
tour_code "815ZU"
designator "PP5"
agent_comment "по классам Y, B, M, U, H у них комиссия 5%"
subagent_comment "3%"
subclasses "YBMUH"
routes "AT,CH,DE,FR,IT,NL,ES,GB,IE,BE,DK,FI,GR,LU,NO,PT,SE,TR,AE,BH,IL,KW,QA,BA,BG,CY,CZ,HR,HU,MD,ME,MK,MT,PL,RO,RS,SI,SK,AL,AM,AZ,BY,EE,GE,KG,KZ,LT,LV,RU,TM,UA,UZ,AF,IQ,JO,LB,OM,SA,SY,YE,AO,BF,BJ,CD,CG,CI,CM,CV,DJ,DZ,ER,GA,GH,GM,GN,GQ,GW,LR,LY,MA,MG,ML,MU,MW,MZ,NA,NG,SC,SL,SN,SD,ST,TG,TN,ZA,ZM,ZW,BD,LK,MV,PK,EG,IR,BI,ET,KE,RW,SD,TZ,UG-US/ALL"
international
example "svojfk/y"
example "svojfk/y jfksvo/m"
end

