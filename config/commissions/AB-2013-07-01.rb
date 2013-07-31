carrier "AB", start_date: "2013-07-01"

example "cdgfra/m fracdg/s"
comment "только собственные рейсы AB и HG"
agent "8% по всем направлениям через DTT"
subagent "6% по всем направлениям через DTT"
discount "4.5%"
ticketing_method "downtown"
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
commission "8%/6%"

example "cdgfra/m fracdg/s"
agent "5% (3%) (3%) за все опубл. тарифы, включая групповые (комиссия не распространяется на:топливный сбор, сбор за безопасность и все остальные сборы, а также на дополнительные услуги)."
agent "Период бронирования и выписки: С 5 по 31.07.2013г (включительно)."
agent "Период путешествия: Любые даты, начиная с 5 июня 2013 г."
agent "Применяется только к рейсам, выполняемым airberlin group (AB/HG/4T). Билеты должны быть выписаны на бланках AB/745."
consolidator "2%"
discount "1.5%"
ticketing_method "aviacenter"
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
disabled "пока dtt?"
commission "5%/3%"

example "cdgfra/S7:AB"
example "cdgsvo svocdg/lh"
agent "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent "5 коп с билета по опубл. тарифам на рейсы AB"
interline :no, :unconfirmed
consolidator "2%"
our_markup "0%"
ticketing_method "direct"
commission "1/0.05"

example "svocdg/s7"
no_commission

