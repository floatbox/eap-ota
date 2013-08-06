carrier "OK"

rule 1 do
example "svocdg"
example "cdgsvo svocdg/ab"
agent_comment "1% от опубл. тарифов на собств.рейсы OK;"
agent_comment "1% от опубл. тарифов на рейсы Interline, если один из сегментов выполнен под кодом OK."
subagent_comment "0.5%"
interline :no, :yes
discount "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

