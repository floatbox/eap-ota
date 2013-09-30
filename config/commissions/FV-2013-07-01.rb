carrier "FV", start_date: "2013-07-01"

rule 1 do
ticketing_method "aviacenter"
agent "4%"
subagent "2%"
discount "2%"
agent_comment "4% (2%) (2%) от опубл. тарифов на собств. (включая code-share) рейсы FV и рейсы Interline c участком FV"
subagent_comment "2% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 2 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "1%"
agent_comment "1 euro  (5 руб+2% сбор АЦ) (0%) с билета на рейсы Interline без участка FV."
subagent_comment "5 рублей"
interline :absent
example "svocdg/ab"
example "svocdg/ab cdgsvo/ab"
end

rule 3 do
no_commission "закрыли субсидированные тарифы"
important!
ticketing_method "aviacenter"
subclasses "R"
example "svocdg/r"
end

