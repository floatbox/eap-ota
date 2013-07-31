carrier "JL"

example "okosvo"
agent "7% от опубл. тарифа;"
subagent "5% от опубл. тарифа;"
international
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svooko okosvo/ab"
agent "7% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
agent "Оформление авиабилетов на бланках JAL по Interline  (в случае наличия рейсов других авиакомпаний) возможно  при условии  наличия  соглашения с соответствующей авиакомпанией и хотя бы одного сегмента с международным рейсом JAL."
agent "Комиссия 7%, в этом случае,  выплачивается только, если авиабилет оформлен по опубликованным тарифам IATA (если при расчете тарифа используются  carrier fares"
agent "других авиакомпаниях, то комиссия с них не выплачивается)."
subagent "5% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
interline :yes
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "okoaoj"
agent "5% от тарифов на внутренние рейсы по Японии"
subagent "3,5% от тарифов на внутренние рейсы по Японии"
domestic
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

