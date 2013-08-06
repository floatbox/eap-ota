carrier "CZ"

rule 1 do
example "svocdg"
agent_comment "9% от тарифа на рейсы, полностью выполняемые CZ;"
subagent_comment "7% от тарифа на рейсы, полностью выполняемые CZ;"
discount "7%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "7% от тарифа на рейсы CZ с участием других перевозчиков;"
subagent_comment "5% от тарифа на рейсы CZ с участием других перевозчиков;"
interline :yes
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 3 do
example "cdgsvo/ab"
agent_comment "0% от тарифа на рейсы Interline без участка СZ."
subagent_comment "0% от тарифа на рейсы Interline без участка СZ."
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

