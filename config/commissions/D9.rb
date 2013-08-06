carrier "D9"

rule 1 do
example "svocdg/economy"
agent_comment "7% от опубл. тарифов эконом класса на собств. рейсы D9"
subagent_comment "5% от опубл. тарифов эконом класса на собств. рейсы D9"
classes :economy
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "svocdg/business"
agent_comment "9% от опубл. тарифов бизнес класса на собств. рейсы D9"
subagent_comment "6,3% от опубл. тарифов бизнес класса на собств. рейсы D9"
classes :business
discount "6.3%"
ticketing_method "aviacenter"
agent "9%"
subagent "6.3%"
end

rule 3 do
example "svocdg cdgsvo/ab"
example "svocdg/business cdgsvo/ab"
agent_comment "2% от опубл. тарифов на рейсы Interline с участком D9"
subagent_comment "1,4% от опубл. тарифов на рейсы Interline с участком D9"
interline :yes
discount "0%"
ticketing_method "aviacenter"
agent "2%"
subagent "1.4%"
end

