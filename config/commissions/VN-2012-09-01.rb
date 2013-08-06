carrier "VN", start_date: "2012-09-01"

rule 1 do
example "svohan hansvo"
agent_comment "C 01.09.12г. 3% от опубл. тарифов на междунар.рейсах VN;"
subagent_comment "2% от опубл. тарифов на междунар.рейсах VN;"
international
discount "1%"
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
end

rule 2 do
example "hansgn"
agent_comment "3% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent_comment "2% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
discount "1%"
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
end

rule 3 do
example "hansgn/ab sgnhan"
agent_comment "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent_comment "C 01.09.12г. 0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

