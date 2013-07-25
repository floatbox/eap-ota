carrier "CI"

example "svocdg"
agent "1% от всех опубл. тарифов на рейсы CI (В договоре Interline отдельно не прописан.)"
subagent "0,5% от опубл. тарифа на собств. рейсы CI"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "cdgsvo svocdg/ab"
agent "1р Interline не прописан"
subagent "0р Interline не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/0"

