carrier "QR", start_date: "2013-06-01"

example "cdgpek/business pekcdg/business"
agent "от опубл. тарифов, а также от опубл. IT гросс тарифов (искл.групповые тарифы) на собств.рейсы QR: 5% Бизнес класс"
subagent "3,5% от опубл. тарифов на собственные рейсы QR"
classes :first, :business
discount "1.75%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "cdgpek/economy pekcdg/economy"
example "cdgpek/business pekcdg/economy"
agent "0.1% Эконом класса, а также при различной комбинации Бизнес/Эконом"
subagent "5 коп. с билета Эконом класса, а также при различной комбинации Бизнес/Эконом;"
consolidator "2%"
ticketing_method "aviacenter"
commission "0.1%/0.05"

example "jfksvo"
example "jfkled ledcdg"
agent "с сегодня на QR если в маршруте есть Россия (OW/RT, origin/destination) - агентская 5%"
subagent "у нас 3%"
important!
discount "1.5%"
ticketing_method "downtown"
tour_code "USAN002"
check %{ includes(country_iatas, 'RU') }
commission "5%/3%"

example "svocdg cdgsvo/ab"
agent "0.1% на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
subagent "5 коп на опубл. гросс тарифы в случае комбинации с другими авиакомпаниями (вознаграждение выплачивается лишь в случаях, когда хотя бы один полетный сегмент забронирован под кодом QR и весь маршрут выписан одним билетом). +сбор АЦ 2% от тарифа Интерлайн без участия перевозчика –  запрещен  !!!"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "0.1%/0.05"

example "cdgsvo/ab"
no_commission

