carrier "SU", start_date: "2013-07-01"

rule 1 do
example "jfksvo svojfk"
agent_comment "правила для выписки авиакомпании SU в DTT"
agent_comment "При вылете из США - все классы - агентская 9%, субагентская 8%, скидка 7%"
subagent_comment "8%"
routes "US..."
discount "8%"
ticketing_method "downtown"
agent "9%"
subagent "8%"
end

rule 2 do
example "cdgsvo svocdg"
agent_comment "правила для выписки авиакомпании SU в DTT"
agent_comment "При вылете НЕ из России - все классы - агентская 5%, субагентская   4.5%, скидка 4%"
subagent_comment "4.5%"
discount "4.5%"
ticketing_method "downtown"
check %{ not includes(country_iatas.first, 'RU') and not includes(city_iatas, 'TLV') }
agent "5%"
subagent "4.5%"
end

rule 3 do
example "svobkk bkksvo"
agent_comment "Коля: SU на dtt 5%/4.5%/4.2%, кроме тель-авива и SU#1"
subagent_comment "4.5%"
discount "2.25%"
ticketing_method "downtown"
check %{ not includes(city_iatas, 'TLV') }
disabled "Включаем SU#4"
agent "5%"
subagent "4.5%"
end

rule 4 do
example "svocdg"
example "svocdg cdgsvo"
example "svocdg/su cdgsvo/ab"
agent_comment "4%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment "3%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
routes "RU..."
discount "3%"
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
end

rule 5 do
example "cdgsvo"
example "cdgsvo/ab svocdg/su"
agent_comment "1 евро с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment "5 (пять) руб. с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes_only(country_iatas.first, 'RU') }
disabled "Выписываем такое в dtt"
agent "1eur"
subagent "5"
end

rule 6 do
example "cdgsvo/ab"
agent_comment "1 евро с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, 'нетто'."
subagent_comment "5 (пять) руб.  с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, нетто'."
interline :absent
consolidator "3.5%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 7 do
example "odssvo svoods/VV"
interline :no, :yes, :absent
routes "...SIP,ODS..."
important!
ticketing_method "aviacenter"
no_commission "Катя просила выключить срочно от 14.06.12"
end

rule 8 do
example "svocdg/p"
subclasses "P"
important!
ticketing_method "aviacenter"
no_commission "закрыли субсидированные тарифы"
end

