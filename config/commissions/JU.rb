carrier "JU"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "1.5%"
agent_comment "С 15.02.2011г. 7% от опубл. тарифов на собств. рейсы JU"
subagent_comment "JU  С 21.02.2011г. 5% от опубл. тарифов на собств. рейсы JU"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
our_markup "150"
consolidator "2%"
agent_comment "С 15.02.2011г. 0% от опубл. тарифов на рейсы Interline"
subagent_comment "С 21.02.2011г. 0% от опубл. тарифов на рейсы Interline"
interline :yes
example "svocdg cdgsvo/ab"
end

