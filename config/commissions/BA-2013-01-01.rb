carrier "BA", start_date: "2013-01-01"

rule 1 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
consolidator "2%"
agent_comment "C 01.01.2013г. 1 рубль с билета по опубл. тарифам на собств. рейсы BA;"
subagent_comment "5 коп. с билета"
example "svocdg"
end

rule 2 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
consolidator "2%"
agent_comment "1 рубль с билета по опубл. тарифам на рейсы Interline, с участком BA. (British Airways и другие перевозчики (oneworld и авиакомпании имеющие договор interline с British Airways), выписанные на одном бланке. Правило первого перевозчика не является обязательным, то есть первый перелет может быть выполнен другой авиакомпанией. Не  разрешается использование бланков ВА для выписки других перевозчиков "
agent_comment "(даже авиакомпаний членов альянса oneworld) без участия ВА. Нарушение этого правила повлечет за собой ADM на сумму GBP 100."
subagent_comment "5 коп. с билета"
interline :yes
example "svocdg cdgsvo/ab"
end

rule 3 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "0"
subagent "0"
consolidator "2%"
agent_comment "0 руб - рейсы авиакомпаний American Airlines, Iberia, OpenSkies и Qantas, выписанные на бланке без перелетного сегмента British Airways."
subagent_comment "0, больше агентской быть не может же"
interline :absent
check %{ includes_only(marketing_carrier_iatas, %W(AA IB EC QF)) }
example "svocdg/aa cdgsvo/aa"
example "svocdg/ib cdgsvo/ib"
example "svocdg/qf cdgsvo/qf"
example "svocdg/ec cdgsvo/ec"
end

