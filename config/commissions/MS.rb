carrier "MS"

example "svocai caisvo"
agent "9% от тарифа на рейсы MS из Москвы"
subagent "7% от тарифа на рейсы MS из Москвы"
routes "MOW..."
discount "5.5%"
ticketing_method "aviacenter"
commission "9%/7%"

example "caisvo svocai"
agent "5% от тарифа на рейсы MS из Египта"
subagent "3,5% от тарифа на рейсы MS из Египта"
routes "EG..."
international
discount "2.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "cdgcai"
example "KULCAI"
agent "5% от тарифа для иных международных рейсов MS"
subagent "3,5% от тарифа для иных международных рейсов MS"
international
discount "2.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "caihrg"
agent "0% от тарифа на рейсы MS внутри Египта"
subagent "0% от тарифа на рейсы MS внутри Египта"
domestic
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

example "caisvo svocai/su"
agent "0% от тарифа на все иные сектора авиабилетов Interline"
subagent "0% от тарифа на все иные сектора авиабилетов Interline"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "0%/0%"

