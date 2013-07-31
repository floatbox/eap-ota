carrier "CZ"

example "svocdg"
agent "9% от тарифа на рейсы, полностью выполняемые CZ;"
subagent "7% от тарифа на рейсы, полностью выполняемые CZ;"
discount "7%"
ticketing_method "aviacenter"
commission "9%/7%"

example "cdgsvo svocdg/ab"
agent "7% от тарифа на рейсы CZ с участием других перевозчиков;"
subagent "5% от тарифа на рейсы CZ с участием других перевозчиков;"
interline :yes
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "cdgsvo/ab"
agent "0% от тарифа на рейсы Interline без участка СZ."
subagent "0% от тарифа на рейсы Interline без участка СZ."
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

