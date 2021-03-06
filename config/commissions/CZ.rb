carrier "CZ"

rule 1 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
agent_comment "9% от тарифа на рейсы, полностью выполняемые CZ;"
subagent_comment "7% от тарифа на рейсы, полностью выполняемые CZ;"
example "svocdg"
end

rule 2 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
agent_comment "7% от тарифа на рейсы CZ с участием других перевозчиков;"
subagent_comment "5% от тарифа на рейсы CZ с участием других перевозчиков;"
interline :yes
example "cdgsvo svocdg/ab"
end

rule 3 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
agent_comment "0% от тарифа на рейсы Interline без участка СZ."
subagent_comment "0% от тарифа на рейсы Interline без участка СZ."
interline :absent
example "cdgsvo/ab"
end

