carrier "S3"

rule 1 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
consolidator "2%"
agent_comment "1 (один) % от всех опубл. тарифов на собств. рейсы S3"
subagent_comment "5 руб. от всех опубл. тарифов на собств. рейсы S3"
example "svocdg cdgsvo"
end

