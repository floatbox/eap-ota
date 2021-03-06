carrier "SK"

rule 1 do
disabled "dtt disabled"
ticketing_method "direct"
agent "12%"
subagent "10%"
agent_comment "через DTT из России в США и наоборот - 12%"
subagent_comment "через DTT из России в США и наоборот - 10%"
interline :no, :yes
subclasses "CDYSEHM"
routes "...US,CA..."
example "svojfk"
example "svojfk jfksvo/ab"
end

rule 2 do
disabled "dtt disabled"
ticketing_method "direct"
agent "8%"
subagent "6%"
comment "subclasses JZBQVWKLT"
agent_comment "через DTT из России в США и наоборот - 8%"
subagent_comment "через DTT из России в США и наоборот - 6%"
interline :no, :yes
routes "...US,CA..."
example "svojfk/Q"
example "svojfk/Q jfksvo/ab/Q"
end

rule 3 do
ticketing_method "direct"
agent "1"
subagent "0.5"
agent_comment "1 руб. с билета на рейсы SAS. (Билеты «Интерлайн» под кодом Авиакомпании могут быть выписаны только в случае существования опубл. тарифов и только при условии, если Авиакомпания выполняет хотя бы один рейс.)"
subagent_comment "50 коп. с билета на рейсы SAS"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

