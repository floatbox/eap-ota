carrier "DE", start_date: "2011-10-01"

example "svocdg"
agent "1руб от всех опубл. тарифов на рейсы DE. (В договоре Interline не прописан.)"
subagent "5 коп от опубл. тарифа на рейсы DE."
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0.05"

example "cdgsvo svocdg/ab"
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/0.05"

