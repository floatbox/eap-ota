carrier "CM"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "1.5%"
consolidator "2%"
agent_comment "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent_comment "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
example "svocdg cdgsvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "1.5%"
consolidator "2%"
agent_comment "1 (один) % от всех опубл. и спец. тарифов на собств. рейсы CM. (Interliтe без участка CM запрещен)."
subagent_comment "5 руб. от всех опубл. и спец. тарифов на собств. рейсы CM. (Interline без участка CM запрещен)."
interline :yes
example "svocdg/ab cdgsvo"
end

