carrier "KL", start_date: "2013-05-15"

rule 1 do
disabled "aviacenter shutdown"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
agent_comment "1руб за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 1руб за билет, выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent_comment "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
example "svocdg"
end

