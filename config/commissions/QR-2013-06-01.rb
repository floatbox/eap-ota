carrier "QR", start_date: "2013-06-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "5.25%"
agent_comment "от опубл. тарифов, а также от опубл. IT гросс тарифов (искл.групповые тарифы) на собств.рейсы QR: 5% Бизнес класс"
subagent_comment "3,5% от опубл. тарифов на собственные рейсы QR"
classes :first, :business
example "cdgpek/business pekcdg/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "0.1%"
subagent "0.05"
discount "2.75%"
consolidator "2%"
agent_comment "0.1% Эконом класса, а также при различной комбинации Бизнес/Эконом"
subagent_comment "5 коп. с билета Эконом класса, а также при различной комбинации Бизнес/Эконом;"
example "cdgpek/economy pekcdg/economy"
example "cdgpek/business pekcdg/economy"
end

rule 3 do
important!
ticketing_method "downtown"
agent "5%"
subagent "3%"
discount "4%"
tour_code "USAN002"
agent_comment "с сегодня на QR если в маршруте есть Россия (OW/RT, origin/destination) - агентская 5%"
subagent_comment "у нас 3%"
check %{ includes(country_iatas, 'RU') }
example "jfksvo"
example "jfkled ledcdg"
end

rule 4 do
ticketing_method "aviacenter"
agent "0.1%"
subagent "0.05"
discount "2.75%"
consolidator "2%"
agent_comment "0.1% на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
subagent_comment "5 коп на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
interline :yes
example "svocdg cdgsvo/ab"
end

rule 5 do
no_commission
example "cdgsvo/ab"
end

