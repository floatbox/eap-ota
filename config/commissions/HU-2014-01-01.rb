carrier "HU", start_date: "2014-01-01"

rule 1 do
agent "9%"
subagent "7%"
agent_comment "9% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent_comment "7% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
example "svopek peksvo"
end

rule 2 do
important!
agent "0%"
subagent "0%"
consolidator "2%"
routes "BJS..."
domestic
example "pekxmn"
end

