carrier "OA"

example "svocdg"
agent "1% от опубл. тарифов на собственные рейсы OA (В договоре Interline не прописан.)"
subagent "5 руб. с билета по опубл. тарифам на собств.рейсы OA"
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/5"

example "cdgsvo svocdg/ab"
agent "1% от опубл. тарифов на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
subagent "5 руб. с билета по опубл. тарифам на рейсы Interline с обязательным участием OA.Выписка по Interline без участия OA не разрешается."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/5"

example "cdgsvo/ab svocdg/ab"
no_commission

