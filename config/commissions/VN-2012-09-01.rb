carrier "VN", start_date: "2012-09-01"

rule 1 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "1.6%"
agent_comment "C 01.09.12г. 3% от опубл. тарифов на междунар.рейсах VN;"
subagent_comment "2% от опубл. тарифов на междунар.рейсах VN;"
international
example "svohan hansvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "1.6%"
agent_comment "3% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent_comment "2% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
example "hansgn"
end

rule 3 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
our_markup "80"
consolidator "2%"
agent_comment "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent_comment "C 01.09.12г. 0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
example "hansgn/ab sgnhan"
end

