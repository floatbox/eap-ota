carrier "LY", start_date: "2013-09-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "4.5%"
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
discount "4.5%"
agent_comment "5% от опубл. тарифов Бизнес класса J на рейсы LY"
subagent_comment "3,5% от опубл. тарифов Бизнес класса J на рейсы LY"
subclasses "JZA"
example "svocdg/j cdgsvo/z"
end

rule 3 do
important!
ticketing_method "aviacenter"
agent "9.7%"
subagent "6.7%"
discount "7.699999999999999%"
agent_comment "9,7% от опубл. тарифов Бизнес класса на рейсы LY"
subagent_comment "6,7% от опубл. тарифов Бизнес класса на рейсы LY"
subclasses "FCID"
example "svocdg/f cdgsvo/c"
example "svocdg/i cdgsvo/d"
end

rule 4 do
no_commission
example "svocdg cdgsvo/business"
example "svocdg cdgsvo/ab"
end

