carrier "CM"

rule 1 do
example "svocdg cdgsvo"
agent_comment "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent_comment "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

rule 2 do
example "svocdg/ab cdgsvo"
agent_comment "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent_comment "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

