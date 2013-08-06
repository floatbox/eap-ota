carrier "JU"

rule 1 do
example "svocdg"
agent_comment "С 15.02.2011г. 7% от опубл. тарифов на собств. рейсы JU"
subagent_comment "JU  С 21.02.2011г. 5% от опубл. тарифов на собств. рейсы JU"
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "С 15.02.2011г. 0% от опубл. тарифов на рейсы Interline"
subagent_comment "С 21.02.2011г. 0% от опубл. тарифов на рейсы Interline"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

