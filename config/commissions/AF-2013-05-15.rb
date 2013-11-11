carrier "AF", start_date: "2013-05-15"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "3%"
agent_comment "1 руб. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ;"
agent_comment "1 руб. за билет,выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent_comment "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ, 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 2 do
no_commission
example "cdgsvo/ab"
end

