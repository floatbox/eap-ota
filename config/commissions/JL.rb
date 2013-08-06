carrier "JL"

rule 1 do
example "okosvo"
agent_comment "7% от опубл. тарифа;"
subagent_comment "5% от опубл. тарифа;"
international
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "svooko okosvo/ab"
agent_comment "7% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
agent_comment "Оформление авиабилетов на бланках JAL по Interline  (в случае наличия рейсов других авиакомпаний) возможно  при условии  наличия  соглашения с соответствующей авиакомпанией и хотя бы одного сегмента с международным рейсом JAL."
agent_comment "Комиссия 7%, в этом случае,  выплачивается только, если авиабилет оформлен по опубликованным тарифам IATA (если при расчете тарифа используются  carrier fares"
agent_comment "других авиакомпаниях, то комиссия с них не выплачивается)."
subagent_comment "5% от опубл. тарифа в случае наличия рейсов других авиакомпаний;"
interline :yes
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 3 do
example "okoaoj"
agent_comment "5% от тарифов на внутренние рейсы по Японии"
subagent_comment "3,5% от тарифов на внутренние рейсы по Японии"
domestic
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

