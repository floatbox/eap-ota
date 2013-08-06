carrier "RB"

rule 1 do
example "svocdg"
agent_comment "7% от всех опубл. тарифов на рейсы RB (В договоре Interline не прописан.)"
subagent_comment "5% от опубл. тарифов на рейсы RB"
discount "2.5%"
ticketing_method "aviacenter"
disabled "Катя сказала выключить, потому что война"
agent "7%"
subagent "5%"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
discount "2.5%"
ticketing_method "aviacenter"
disabled "Катя сказала выключить, потому что война"
agent "7%"
subagent "5%"
end

