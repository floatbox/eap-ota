carrier "SU", start_date: "2013-07-01"

example "jfksvo svojfk"
agent "правила для выписки авиакомпании SU в DTT"
agent "При вылете из США - все классы - агентская 9%, субагентская 8%, скидка 7%"
subagent "8%"
routes "US..."
discount "4%"
ticketing_method "downtown"
commission "9%/8%"

example "cdgsvo svocdg"
agent "правила для выписки авиакомпании SU в DTT"
agent "При вылете НЕ из России - все классы - агентская 5%, субагентская   4.5%, скидка 4%"
subagent "4.5%"
discount "2.25%"
ticketing_method "downtown"
check %{ not includes(country_iatas.first, 'RU') and not includes(city_iatas, 'TLV') }
commission "5%/4.5%"

example "svobkk bkksvo"
agent "Коля: SU на dtt 5%/4.5%/4.2%, кроме тель-авива и SU#1"
subagent "4.5%"
discount "2.25%"
ticketing_method "downtown"
check %{ not includes(city_iatas, 'TLV') }
disabled "Включаем SU#4"
commission "5%/4.5%"

example "svocdg"
example "svocdg cdgsvo"
example "svocdg/su cdgsvo/ab"
agent "4%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent "3%  от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
routes "RU..."
discount "1.5%"
ticketing_method "aviacenter"
commission "4%/3%"

example "cdgsvo"
example "cdgsvo/ab svocdg/su"
agent "1 евро с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent "5 (пять) руб. с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
interline :no, :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes_only(country_iatas.first, 'RU') }
disabled "Выписываем такое в dtt"
commission "1eur/5"

example "cdgsvo/ab"
agent "1 евро с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, 'нетто'."
subagent "5 (пять) руб.  с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским, конфиденциальным, нетто'."
interline :absent
consolidator "3.5%"
ticketing_method "aviacenter"
commission "1eur/5"

example "odssvo svoods/VV"
interline :no, :yes, :absent
routes "...SIP,ODS..."
important!
ticketing_method "aviacenter"
no_commission "Катя просила выключить срочно от 14.06.12"

example "svocdg/p"
subclasses "P"
important!
ticketing_method "aviacenter"
no_commission "закрыли субсидированные тарифы"

