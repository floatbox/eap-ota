carrier "7D", start_date: "2011-04-11"

rule 1 do
disabled "out of BSP"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "1.75%"
agent_comment "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent_comment "С 11.04.11г. 3,5% от всех опубл. тарифов на собств. рейсы 7D;"
example "svocdg"
end

rule 2 do
disabled "out of BSP"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "1.75%"
agent_comment "С 11.04.11г. 5 (Пять) % от всех опубликованных тарифов на интерлайн-перевозки как с участием собственных, так и без участия собственных рейсов (только рейсы интерлайн-партнёров) авиакомпании DONBASSAERO AIRLINES (LLC) (7D/897);"
subagent_comment "С 11.04.11г. 3,5% от всех опубл. тарифов на рейсы Interline с уч. собств. рейсов 7D;"
interline :yes, :absent
example "cdgsvo svocdg/ab"
end

