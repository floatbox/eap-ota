carrier "AF", start_date: "2013-05-15"

rule 1 do
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "7%"
agent_comment "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent_comment "Если, кратко, то C,D,Z,I W,S,Y,M,U,K,H A,L,Q,T,N,R,V"
agent_comment "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent_comment "6%"
subclasses "CDZIWSYMUKHALQTNRV"
routes "US-RU/OW,RT"
example "jfksvo/c svojfk/n"
example "jfksvo/v"
end

rule 2 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "1%"
agent_comment "1 руб. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ;"
agent_comment "1 руб. за билет,выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent_comment "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ, 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 3 do
no_commission
example "cdgsvo/ab"
end

