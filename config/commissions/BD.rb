carrier "BD"

rule 1 do
example "svocdg"
example "svocdg cdgsvo/ab"
agent_comment "1 руб. с билета по опубл.тарифам"
subagent_comment "5 коп. с билета по опубл. тарифам на собств. рейсы BD и рейсы Interline с участком BD"
interline :no, :yes
our_markup "0.2%"
ticketing_method "aviacenter"
disabled "вышли из bsp"
agent "1"
subagent "0.05"
end

rule 2 do
example "svocdg/ab"
no_commission
end

