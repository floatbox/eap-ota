carrier "TN"

rule 1 do
example "svocdg"
agent_comment "1 (Один) рубль от всех опубл. тарифов на собств.рейсы авиакомпании TN"
subagent_comment "5 коп. с билета по опубл. тарифам на собств. рейсы TN"
interline :no, :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

