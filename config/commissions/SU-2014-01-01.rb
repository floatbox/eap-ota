carrier "SU", start_date: "2014-01-01"

rule 1 do
ticketing_method "aviacenter"
agent "0.1%"
subagent "5"
consolidator "2%"
agent_comment "С 01.01.2014г. 0,1% от тарифа на собств. рейсы SU с началом перевозки из РФ (вкл. рейсы по согл. «Код-шеринг» и рейсы Interline с участком SU, а также по субсидированным перевозкам);"
subagent_comment "30 okt 2013 — субагентской пока нет"
interline :no, :yes, :absent
example "svotlv/su tlvsvo"
example "cdgsvo/ab svocdg/su"
example "cdgsvo/ab"
end

rule 3 do
ticketing_method "aviacenter"
disabled "не умеем"
agent "1"
subagent "0.05"
consolidator "2%"
agent_comment "С 01.01.2014г. 1 евро с билета при продаже под кодом SU по групповым, договорным, туроператорским и конфиденциальным тарифам. "
end

