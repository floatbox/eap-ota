carrier "TG"

rule 1 do
example "svobkk"
agent_comment "С 01.02.2011г. 5% от всех опубл.и конфиденциальных тарифов на международные рейсы TG"
subagent_comment "С 01.02.2011г. 3% от опубл. и конфиде.тарифов на международные рейсы TG"
international
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 2 do
example "bkkdmk"
agent_comment "С 01.02.2011г. 0% от всех опубл. тарифов на внутренние рейсы TG"
subagent_comment "С 01.02.2011г. 0% от опубл.тарифов на внутренние рейсы TG"
domestic
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 3 do
example "svobkk/su bkkdmk"
agent_comment "0% от тарифов на рейсы Interline. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
subagent_comment "0% от опубл. тарифа на рейсы Interline с участком TG. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

