carrier "MS"

rule 1 do
example "svocai caisvo"
agent_comment "9% от тарифа на рейсы MS из Москвы"
subagent_comment "7% от тарифа на рейсы MS из Москвы"
routes "MOW..."
discount "7%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 2 do
example "caisvo svocai"
agent_comment "5% от тарифа на рейсы MS из Египта"
subagent_comment "3,5% от тарифа на рейсы MS из Египта"
routes "EG..."
international
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 3 do
example "cdgcai"
example "KULCAI"
agent_comment "5% от тарифа для иных международных рейсов MS"
subagent_comment "3,5% от тарифа для иных международных рейсов MS"
international
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 4 do
example "caihrg"
agent_comment "0% от тарифа на рейсы MS внутри Египта"
subagent_comment "0% от тарифа на рейсы MS внутри Египта"
domestic
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 5 do
example "caisvo svocai/su"
agent_comment "0% от тарифа на все иные сектора авиабилетов Interline"
subagent_comment "0% от тарифа на все иные сектора авиабилетов Interline"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

