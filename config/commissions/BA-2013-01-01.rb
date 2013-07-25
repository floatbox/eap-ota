carrier "BA", start_date: "2013-01-01"

example "svocdg"
agent "C 01.01.2013г. 1 рубль с билета по опубл. тарифам на собств. рейсы BA;"
subagent "5 коп. с билета"
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0.05"

example "svocdg cdgsvo/ab"
agent "1 рубль с билета по опубл. тарифам на рейсы Interline, с участком BA. (British Airways и другие перевозчики (oneworld и авиакомпании имеющие договор interline с British Airways), выписанные на одном бланке. Правило первого перевозчика не является обязательным, то есть первый перелет может быть выполнен другой авиакомпанией. Не  разрешается использование бланков ВА для выписки других перевозчиков "
agent "(даже авиакомпаний членов альянса oneworld) без участия ВА. Нарушение этого правила повлечет за собой ADM на сумму GBP 100."
subagent "5 коп. с билета"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0.05"

example "svocdg/aa cdgsvo/aa"
example "svocdg/ib cdgsvo/ib"
example "svocdg/qf cdgsvo/qf"
example "svocdg/ec cdgsvo/ec"
agent "0 руб - рейсы авиакомпаний American Airlines, Iberia, OpenSkies и Qantas, выписанные на бланке без перелетного сегмента British Airways."
subagent "0, больше агентской быть не может же"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, %W(AA IB EC QF)) }
commission "0/0"

