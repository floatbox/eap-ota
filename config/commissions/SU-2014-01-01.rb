carrier "SU", start_date: "2014-01-01"

rule 1 do
ticketing_method "aviacenter"
agent "0.1%"
subagent ""
agent_comment "С 01.01.2014г. 0,1% от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment "30 okt 2013 — субагентской пока нет"
interline :no, :yes
routes "RU..."
example "svotlv/su tlvsvo"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "1eur"
subagent ""
consolidator "2%"
agent_comment "1 евро с билета на собств. рейсы SU с началом перевозки за пределами РФ (вкл. рейсы по согл. «Код-    шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment ""
interline :yes
check %{ not includes_only(country_iatas.first, 'RU') }
example "cdgsvo/ab svocdg/su"
end

rule 6 do
ticketing_method "aviacenter"
agent "1eur"
subagent ""
consolidator "2%"
agent_comment "1 евро с билета на рейсы Interline без участка SU, а также по тарифам: туроператорским,               конфиденциальным, 'нетто'."
subagent_comment ""
interline :absent
example "cdgsvo/ab"
end
