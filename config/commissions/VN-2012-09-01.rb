carrier "VN", start_date: "2013-09-01"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
consolidator "2%"
agent_comment "С 01.12.13г. 1% (5 руб+сбор АЦ) от опубл. тарифов на междунар.рейсах VN;"
subagent_comment "С 01.12.13г. 1% (5 руб+сбор АЦ) от опубл. тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
international
example "svohan hansvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "3%"
subagent "1%"
discount "2%"
agent_comment "3% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent_comment "2% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
example "hansgn"
end

rule 3 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
agent_comment "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent_comment "C 01.09.12г. 0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
example "hansgn/ab sgnhan"
end

