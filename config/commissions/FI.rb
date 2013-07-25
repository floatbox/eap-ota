carrier "FI"

example "svocdg"
agent "1% от всех опубл. тарифов на рейсы FI (В договоре Interline не прописан.)"
subagent "0,5% от опубл. тарифа на рейсы FI"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "cdgsvo svocdg/ab"
agent "1% от опубл. тарифов на рейсы Interline с обязательным участием FI."
subagent "0,5% от опубл. тарифов на рейсы Interline с обязательным участием FI."
interline :yes
ticketing_method "aviacenter"
commission "1%/0.5%"

