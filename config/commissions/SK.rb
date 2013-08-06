carrier "SK"

rule 1 do
example "svojfk"
example "svojfk jfksvo/ab"
agent_comment "через DTT из России в США и наоборот - 12%"
subagent_comment "через DTT из России в США и наоборот - 10%"
interline :no, :yes
subclasses "CDYSEHM"
routes "...US,CA..."
discount "10%"
ticketing_method "downtown"
agent "12%"
subagent "10%"
end

rule 2 do
example "svojfk/Q"
example "svojfk/Q jfksvo/ab/Q"
comment "subclasses JZBQVWKLT"
agent_comment "через DTT из России в США и наоборот - 8%"
subagent_comment "через DTT из России в США и наоборот - 6%"
interline :no, :yes
routes "...US,CA..."
discount "6%"
ticketing_method "downtown"
agent "8%"
subagent "6%"
end

rule 3 do
example "svocdg"
example "svocdg cdgsvo/ab"
agent_comment "1 руб. с билета на рейсы SAS. (Билеты «Интерлайн» под кодом Авиакомпании могут быть выписаны только в случае существования опубл. тарифов и только при условии, если Авиакомпания выполняет хотя бы один рейс.)"
subagent_comment "50 коп. с билета на рейсы SAS"
interline :no, :yes
our_markup "1.5%"
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
end

