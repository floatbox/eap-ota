carrier "HR", start_date: "2013-07-10"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "1.5%"
consolidator "2%"
comment "включено с дополнительной проверкой"
agent_comment "1 руб. от тарифов, опубликованных в системе бронирования, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com;"
agent_comment "1 руб. от тарифов Allairpass, расчитываемых на сайте www.allairpass.com, для авиакомпании Hahn Air и интерлайн-партнеров Hahn Air, указанных на сайте www.HR-ticketing.com"
agent_comment "Проверять интерлайн при бронировании и выписке через сайт www.hr-ticketing.com"
subagent_comment "5 коп. с билета по опубл. тарифам HR"
interline :no, :absent
example "svocdg"
example "svocdg/qr"
end

rule 2 do
no_commission
important!
ticketing_method "aviacenter"
agent_comment "Настоящим сообщаю вам, что Интерлайн-соглашение между airberlin и Hahn Air прекращает свое действие 9 июля 2013 г."
agent_comment "Рейсы AB/HG нельзя будет выписывать на бланках HR/169, начиная с 10 июля 2013 г."
interline :yes, :absent
check %{ includes(operating_carrier_iatas, 'AB HG') }
example "svocdg/ab"
example "svocdg/hg"
example "svocdg/ab cdgsvo"
example "svocdg/hg cdgsvo"
end

