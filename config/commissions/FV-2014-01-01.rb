carrier "FV", start_date: "2014-01-01"

rule 1 do
ticketing_method "aviacenter"
agent "2.5%"
subagent "1.5%"
agent_comment "С 01.01.14г. по 10.01.14г. 2,5%(1.5%) от опубл. тарифов на собств. (включая code-share) рейсы FV и рейсы Interline c уч.FV"
subagent_comment "1.5% от опубл. тарифов на собств. рейсы FV и рейсы Interline c участком FV"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 2 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
consolidator "2%"
agent_comment "С 01.01.14г. по 10.01.14г. 1 euro (5руб +2% сбор АЦ) с билета на рейсы Interline без уч. FV."
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

