carrier "HR", start_date: "2013-07-10"

example "svocdg"
example "svocdg/qr"
comment "включено с дополнительной проверкой"
agent "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent "5 коп. с билета по опубл. тарифам HR"
interline :no, :absent
consolidator "2%"
our_markup "20"
ticketing_method "aviacenter"
commission "1/0.05"

example "svocdg/ab"
example "svocdg/hg"
example "svocdg/ab cdgsvo"
example "svocdg/hg cdgsvo"
agent "Настоящим сообщаю вам, что Интерлайн-соглашение между airberlin и Hahn Air прекращает свое действие 9 июля 2013 г."
agent "Рейсы AB/HG нельзя будет выписывать на бланках HR/169, начиная с 10 июля 2013 г."
interline :yes, :absent
important!
ticketing_method "aviacenter"
check %{ includes(operating_carrier_iatas, 'AB HG') }
no_commission

