carrier "MS"

rule 1 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "4.9%"
agent_comment "9% от тарифа на рейсы MS из Москвы"
subagent_comment "7% от тарифа на рейсы MS из Москвы"
routes "MOW..."
example "svocai caisvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "2.45%"
agent_comment "5% от тарифа на рейсы MS из Египта"
subagent_comment "3,5% от тарифа на рейсы MS из Египта"
routes "EG..."
international
example "caisvo svocai"
end

rule 3 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "2.45%"
agent_comment "5% от тарифа для иных международных рейсов MS"
subagent_comment "3,5% от тарифа для иных международных рейсов MS"
international
example "cdgcai"
example "KULCAI"
end

rule 4 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "3.5%"
consolidator "2%"
agent_comment "0% от тарифа на рейсы MS внутри Египта"
subagent_comment "0% от тарифа на рейсы MS внутри Египта"
domestic
example "caihrg"
end

rule 5 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "3.5%"
consolidator "2%"
agent_comment "0% от тарифа на все иные сектора авиабилетов Interline"
subagent_comment "0% от тарифа на все иные сектора авиабилетов Interline"
interline :yes
example "caisvo svocai/su"
end

