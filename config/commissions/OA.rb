carrier "OA"

rule 1 do
example "svocdg"
agent_comment "1% от опубл. тарифов на собственные рейсы OA (В договоре Interline не прописан.)"
subagent_comment "5 руб. с билета по опубл. тарифам на собств.рейсы OA"
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1% от опубл. тарифов на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
subagent_comment "5 руб. с билета по опубл. тарифам на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

rule 3 do
example "cdgsvo/ab svocdg/ab"
no_commission
end

