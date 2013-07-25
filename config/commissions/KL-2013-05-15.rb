carrier "KL", start_date: "2013-05-15"

example "jfksvo/c svojfk/n"
example "jfksvo/v"
agent "1232 DL/AFKL/AZ US-EMEAI Consolidator Commission Program Amendment #1"
agent "Если, кратко, то C,D,Z,I W,S,Y,M,U,K,H A,L,Q,T,N,R,V"
agent "Только перелеты в Америку из России и наоборот (RT и OW), только СОБСТВЕННЫЕ рейсы ( никаких код-шерингов), авиакомпании могут комбинироваться в одном бронировании. Их комиссия 8%, наша 6%, никаких особенностей в выписке"
subagent "6%"
subclasses "CDZIWSYMUKHALQTNRV"
routes "RU-US/ALL"
discount "3%"
our_markup "0.1%"
ticketing_method "downtown"
commission "8%/6%"

example "svocdg"
agent "1руб за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 1руб за билет, выписанный по опубл. тарифам,  в случае вылета вне стран СНГ;"
subagent "5 коп. за билет, выписанный по опубл. тарифам, в случае перевозки с вылетом из стран СНГ; 5 коп. за билет, выписанный по опубл. тарифам, в случае вылета вне стран СНГ;"
interline :no, :yes
ticketing_method "aviacenter"
commission "1/0.05"

