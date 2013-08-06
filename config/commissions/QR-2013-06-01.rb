carrier "QR", start_date: "2013-06-01"

rule 1 do
example "cdgpek/business pekcdg/business"
agent_comment "от опубл. тарифов, а также от опубл. IT гросс тарифов (искл.групповые тарифы) на собств.рейсы QR: 5% Бизнес класс"
subagent_comment "3,5% от опубл. тарифов на собственные рейсы QR"
classes :first, :business
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 2 do
example "cdgpek/economy pekcdg/economy"
example "cdgpek/business pekcdg/economy"
agent_comment "0.1% Эконом класса, а также при различной комбинации Бизнес/Эконом"
subagent_comment "5 коп. с билета Эконом класса, а также при различной комбинации Бизнес/Эконом;"
consolidator "2%"
ticketing_method "aviacenter"
agent "0.1%"
subagent "0.05"
end

rule 3 do
example "jfksvo"
example "jfkled ledcdg"
agent_comment "с сегодня на QR если в маршруте есть Россия (OW/RT, origin/destination) - агентская 5%"
subagent_comment "у нас 3%"
important!
discount "3%"
ticketing_method "downtown"
tour_code "USAN002"
check %{ includes(country_iatas, 'RU') }
agent "5%"
subagent "3%"
end

rule 4 do
example "svocdg cdgsvo/ab"
agent_comment "0.1% на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
subagent_comment "5 коп на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "0.1%"
subagent "0.05"
end

rule 5 do
example "cdgsvo/ab"
no_commission
end

