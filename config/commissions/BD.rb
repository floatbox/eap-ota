carrier "BD"

rule 1 do
disabled "вышли из bsp"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2%"
agent_comment "1 руб. с билета по опубл.тарифам"
subagent_comment "5 коп. с билета по опубл. тарифам на собств. рейсы BD и рейсы Interline с участком BD"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 2 do
no_commission
example "svocdg/ab"
end

