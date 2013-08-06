carrier "FV", start_date: "2013-07-01"

rule 1 do
example "svocdg"
example "svocdg cdgsvo/ab"
agent_comment "4% (2%) (2%) от опубл. тарифов на собств. (включая code-share) рейсы FV и рейсы Interline c участком FV"
subagent_comment "2% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
discount "0%"
ticketing_method "aviacenter"
agent "4%"
subagent "2%"
end

rule 2 do
example "svocdg/ab"
example "svocdg/ab cdgsvo/ab"
agent_comment "1 euro  (5 руб+2% сбор АЦ) (0%) с билета на рейсы Interline без участка FV."
subagent_comment "5 рублей"
interline :absent
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 3 do
example "svocdg/r"
subclasses "R"
important!
ticketing_method "aviacenter"
no_commission "закрыли субсидированные тарифы"
end

