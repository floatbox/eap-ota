carrier "LY"

rule 1 do
example "svocdg"
agent_comment "5% от опубл. тарифов Эконом класса на рейсы LY"
subagent_comment "3,5% от опубл. тарифов Эконом класса на рейсы LY"
classes :economy
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 2 do
example "svocdg/j cdgsvo/j"
agent_comment "5% от опубл. тарифов Бизнес класса J на рейсы LY"
subagent_comment "3,5% от опубл. тарифов Бизнес класса J на рейсы LY"
subclasses "J"
important!
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 3 do
example "svocdg/business cdgsvo/business"
agent_comment "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent_comment "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
classes :business
discount "6.7%"
ticketing_method "aviacenter"
agent "9.7%"
subagent "6.7%"
end

rule 4 do
example "svocdg cdgsvo/business"
example "svocdg cdgsvo/ab"
no_commission
end

