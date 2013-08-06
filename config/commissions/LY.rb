carrier "LY"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "3.5%"
agent_comment "5% от опубл. тарифов Эконом класса на рейсы LY"
subagent_comment "3,5% от опубл. тарифов Эконом класса на рейсы LY"
classes :economy
example "svocdg"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "3.5%"
agent_comment "5% от опубл. тарифов Бизнес класса J на рейсы LY"
subagent_comment "3,5% от опубл. тарифов Бизнес класса J на рейсы LY"
subclasses "J"
example "svocdg/j cdgsvo/j"
end

rule 3 do
ticketing_method "aviacenter"
agent "9.7%"
subagent "6.7%"
discount "6.7%"
agent_comment "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent_comment "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
classes :business
example "svocdg/business cdgsvo/business"
end

rule 4 do
no_commission
example "svocdg cdgsvo/business"
example "svocdg cdgsvo/ab"
end

