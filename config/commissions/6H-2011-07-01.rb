carrier "6H", start_date: "2011-07-01"

example "svocdg"
agent "С 01.07.11г. 5% от всех опубл. тарифов на рейсы 6H (В договоре Interline отдельно не прописан.)"
subagent "С 01.07.11г. 3% от опубл. тарифов на собств.рейсы 6H"
discount "3%"
ticketing_method "aviacenter"
commission "5%/3%"

example "cdgsvo svocdg/ab"
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0"

