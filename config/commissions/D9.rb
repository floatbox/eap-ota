carrier "D9"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6.25%"
agent_comment "7% от опубл. тарифов эконом класса на собств. рейсы D9"
subagent_comment "5% от опубл. тарифов эконом класса на собств. рейсы D9"
classes :economy
example "svocdg/economy"
end

rule 2 do
ticketing_method "aviacenter"
agent "9%"
subagent "6.3%"
discount "7.55%"
agent_comment "9% от опубл. тарифов бизнес класса на собств. рейсы D9"
subagent_comment "6,3% от опубл. тарифов бизнес класса на собств. рейсы D9"
classes :business
example "svocdg/business"
end

rule 3 do
ticketing_method "aviacenter"
agent "2%"
subagent "1.4%"
discount "2.65%"
agent_comment "2% от опубл. тарифов на рейсы Interline с участком D9"
subagent_comment "1,4% от опубл. тарифов на рейсы Interline с участком D9"
interline :yes
example "svocdg cdgsvo/ab"
example "svocdg/business cdgsvo/ab"
end

