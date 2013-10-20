carrier "AY"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
discount "1.5%"
our_markup "80"
consolidator "2%"
agent_comment "1 руб. с билета на рейсы AY (Билеты «Интерлайн» под кодом АY могут быть выписаны только в случае использования опубл. тарифов или тарифов ИАТА и только при условии, если АY выполняет хотя бы один рейс при наличии действующих «Интерлайн» соглашений с другими а/к, задействованными в перевозке.)"
subagent_comment "50 коп. с билета на рейсы AY"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 2 do
no_commission
example "cdgsvo/ab"
end

