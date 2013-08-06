carrier "AB", start_date: "2013-07-01"

rule 1 do
example "cdgfra/m fracdg/s"
comment "только собственные рейсы AB и HG"
agent_comment "8% по всем направлениям через DTT"
subagent_comment "6% по всем направлениям через DTT"
discount "6%"
ticketing_method "downtown"
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
agent "8%"
subagent "6%"
end

rule 2 do
example "cdgfra/m fracdg/s"
agent_comment "5% (3%) (3%) за все опубл. тарифы, включая групповые (комиссия не распространяется на:топливный сбор, сбор за безопасность и все остальные сборы, а также на дополнительные услуги)."
agent_comment "Период бронирования и выписки: С 5 по 31.07.2013г (включительно)."
agent_comment "Период путешествия: Любые даты, начиная с 5 июня 2013 г."
agent_comment "Применяется только к рейсам, выполняемым airberlin group (AB/HG/4T). Билеты должны быть выписаны на бланках AB/745."
consolidator "2%"
discount "1.5%"
ticketing_method "aviacenter"
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
disabled "пока dtt?"
agent "5%"
subagent "3%"
end

rule 3 do
example "cdgfra/S7:AB"
example "cdgsvo svocdg/lh"
agent_comment "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent_comment "5 коп с билета по опубл. тарифам на рейсы AB"
interline :no, :unconfirmed
consolidator "2%"
our_markup "0%"
ticketing_method "direct"
agent "1"
subagent "0.05"
end

rule 4 do
example "svocdg/s7"
no_commission
end

