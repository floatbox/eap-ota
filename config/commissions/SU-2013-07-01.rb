carrier "SU", start_date: "2013-07-01"

rule 1 do
disabled "с первого сентября - через авиацентр"
ticketing_method "direct"
agent "9%"
subagent "8%"
agent_comment "правила для выписки авиакомпании SU в DTT"
agent_comment "При вылете из США - все классы - агентская 9%, субагентская 8%, скидка 7%"
subagent_comment "8%"
routes "US..."
example "jfksvo svojfk"
end

rule 2 do
disabled "dtt disabled"
ticketing_method "direct"
agent "5%"
subagent "4.5%"
agent_comment "правила для выписки авиакомпании SU в DTT"
agent_comment "При вылете НЕ из России - все классы - агентская 5%, субагентская   4.5%, скидка 4%"
subagent_comment "4.5%"
check %{ not includes(country_iatas.first, 'RU') and not includes(city_iatas, 'TLV') }
example "cdgsvo svocdg"
end

rule 3 do
disabled "dtt disabled"
ticketing_method "direct"
agent "5%"
subagent "4.5%"
agent_comment "Коля: SU на dtt 5%/4.5%/4.2%, кроме тель-авива и SU#1"
subagent_comment "4.5%"
interline :no, :yes
check %{ not includes(city_iatas, 'TLV') }
example "svobkk bkksvo"
example "svocdg"
example "svocdg cdgsvo"
example "svocdg/su cdgsvo/ab"
end

rule 4 do
ticketing_method "direct"
agent "4%"
subagent "3%"
agent_comment "4%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment "3%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
routes "RU..."
example "svotlv/su tlvsvo"
end

rule 5 do
important!
ticketing_method "direct"
agent "1eur"
subagent "5"
consolidator "2%"
agent_comment "1 евро с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment "5 (пять) руб. с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :yes
check %{ not includes_only(country_iatas.first, 'RU') }
example "cdgsvo/ab svocdg/su"
end

rule 6 do
ticketing_method "direct"
agent "1eur"
subagent "5"
consolidator "2%"
agent_comment "1 евро с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, 'нетто'."
subagent_comment "5 (пять) руб.  с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, нетто'."
interline :absent
example "cdgsvo/ab"
end

rule 7 do
no_commission "закрыли субсидированные тарифы"
important!
ticketing_method "aviacenter"
subclasses "P"
example "svocdg/p"
end

