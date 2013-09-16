carrier "AB", start_date: "2013-07-01"

rule 1 do
ticketing_method "downtown"
agent "8%"
subagent "6%"
discount "7.5%"
comment "только собственные рейсы AB и HG"
agent_comment "8% по всем направлениям через DTT"
subagent_comment "6% по всем направлениям через DTT"
check %{ includes_only(operating_carrier_iatas, 'AB HG 4T') }
example "cdgfra/m fracdg/s"
end

rule 2 do
ticketing_method "direct"
agent "1"
subagent "0.05"
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

