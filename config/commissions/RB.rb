carrier "RB", no_commission: "Катя сказала выключить, потому что война"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7% от всех опубл. тарифов на рейсы RB (В договоре Interline не прописан.)"
subagent_comment "5% от опубл. тарифов на рейсы RB"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

