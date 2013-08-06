carrier "AT"

rule 1 do
example "svocdg"
agent_comment "5% от опубл. тарифов Эконом класса на собств. рейсы АТ"
subagent_comment "3% от опубл. тарифов Эконом класса на собств. рейсы АТ"
classes :economy
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 2 do
example "svocdg/business"
agent_comment "7% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
subagent_comment "5% от опубл. тарифов Бизнес класса на собств. рейсы АТ"
classes :business
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 3 do
example "svocdg cdgsvo/ab"
interline :yes, :absent
no_commission
end

