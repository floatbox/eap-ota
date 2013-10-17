carrier "AT"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "0.9%"
agent_comment "5% от опубл. тарифов Эконом класса на собств. рейсы АТ"
subagent_comment "3% от опубл. тарифов Эконом класса на собств. рейсы АТ"
classes :economy
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "1.5%"
agent_comment "7% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
subagent_comment "5% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
classes :business
example "svocdg/business"
end

rule 3 do
no_commission
interline :yes, :absent
example "svocdg cdgsvo/ab"
end

