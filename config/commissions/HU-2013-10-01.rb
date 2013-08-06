carrier "HU", start_date: "2013-10-01"

rule 1 do
important!
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
consolidator "2%"
agent_comment "0% по опубл. тарифам отдельные перелеты с вылетами из Пекина по Китаю на собств. рейсы HU"
subagent_comment "0%"
routes "BJS..."
domestic
example "pekxmn xmnweh"
end

rule 2 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "3.5%"
agent_comment "9% (7%) от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
subagent_comment "7% от всех опубл. тарифов на рейсы HU (В договоре Interline не прописан.)"
example "peksvo svopek"
end

