carrier "TG"

example "svobkk"
agent "С 01.02.2011г. 5% от всех опубл.и конфиденциальных тарифов на международные рейсы TG"
subagent "С 01.02.2011г. 3% от опубл. и конфиде.тарифов на международные рейсы TG"
international
discount "3%"
ticketing_method "aviacenter"
commission "5%/3%"

example "bkkdmk"
agent "С 01.02.2011г. 0% от всех опубл. тарифов на внутренние рейсы TG"
subagent "С 01.02.2011г. 0% от опубл.тарифов на внутренние рейсы TG"
domestic
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

example "svobkk/su bkkdmk"
agent "0% от тарифов на рейсы Interline. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
subagent "0% от опубл. тарифа на рейсы Interline с участком TG. (Билеты по Interline могут быть выписаны только при условии присутствия сегментов TG.)"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

