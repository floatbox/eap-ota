carrier "AB", start_date: "2013-07-01"

rule 1 do
ticketing_method "downtown"
agent "10%"
subagent "8%"
comment "только собственные рейсы AB и HG"
agent_comment "10% по всем направлениям через DTT"
subagent_comment "8% по всем направлениям через DTT"
interline :yes, :no
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') and flights.last.dept_date < Date.new(2014, 12, 31) }
example "cdgfra/m fracdg/s"
example "cdgfra fracdg/hg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
our_markup "100"
consolidator "2%"
agent_comment "1 руб с билета по опубл. тарифам на рейсы AB (В договоре Interline не прописан.)"
subagent_comment "5 коп с билета по опубл. тарифам на рейсы AB"
interline :no, :unconfirmed
example "cdgfra/S7:AB"
example "cdgsvo svocdg/lh"
end

rule 3 do
no_commission
example "svocdg/s7"
end

