carrier "VN", start_date: "2012-09-01"

example "svohan hansvo"
agent "C 01.09.12г. 3% от опубл. тарифов на междунар.рейсах VN;"
subagent "2% от опубл. тарифов на междунар.рейсах VN;"
international
discount "1%"
ticketing_method "aviacenter"
commission "3%/2%"

example "hansgn"
agent "3% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
subagent "2% от опубликованных тарифов VN на всех внутренних рейсах VN во Вьетнаме;"
domestic
discount "1%"
ticketing_method "aviacenter"
commission "3%/2%"

example "hansgn/ab sgnhan"
agent "0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
subagent "C 01.09.12г. 0% от оформленных под кодом 738 опубл.тарифов на рейсы Interline."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

