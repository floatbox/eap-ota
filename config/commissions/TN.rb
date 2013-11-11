carrier "TN"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "3.5%"
consolidator "2%"
agent_comment "1 (Один) рубль от всех опубл. тарифов на собств.рейсы авиакомпании TN"
subagent_comment "5 коп. с билета по опубл. тарифам на собств. рейсы TN"
interline :no, :unconfirmed
example "svocdg"
end

