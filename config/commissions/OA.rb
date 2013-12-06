carrier "OA"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "5.5%"
consolidator "2%"
agent_comment "1% от опубл. тарифов на собственные рейсы OA (В договоре Interline не прописан.)"
subagent_comment "5 руб. с билета по опубл. тарифам на собств.рейсы OA"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "5.5%"
consolidator "2%"
agent_comment "1% от опубл. тарифов на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
subagent_comment "5 руб. с билета по опубл. тарифам на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
interline :yes
example "cdgsvo svocdg/ab"
end

rule 3 do
no_commission
example "cdgsvo/ab svocdg/ab"
end

