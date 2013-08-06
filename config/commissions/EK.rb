carrier "EK"

rule 1 do
example "svocdg/first cdgsvo/business"
example "svocdg/first cdgsvo/first"
agent_comment "5% от тарифов Первого и Бизнес классов на рейсы EK;"
subagent_comment "3,5% от тарифов Первого и Бизнес классов на рейсы EK;"
classes :first, :business
routes "RU..."
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 2 do
example "svocdg/business cdgsvo"
example "svocdg/first cdgsvo"
agent_comment "5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
subagent_comment "3,5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
routes "RU..."
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 3 do
example "svocdg"
agent_comment "1 руб. с билета по опубл.тарифам Эконом класса на рейсы EK."
subagent_comment "5 коп. с билета по опубл.тарифам Эконом класса на собств. рейсы EK."
classes :economy
routes "RU..."
important!
discount "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

rule 4 do
example "jfkcdg"
agent_comment "1 руб. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
subagent_comment "С 01.01.13г. 5 коп. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
ticketing_method "aviacenter"
check %{ not includes_only(country_iatas.first, 'RU') }
agent "1"
subagent "0.05"
end

rule 5 do
example "svocdg/business cdgsvo/ab/business svoled/business ledsvo/business"
agent_comment "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent_comment "3.5%"
interline :less_than_half
classes :first, :business
routes "RU..."
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

rule 6 do
example "svocdg/first cdgsvo/ab/business svoled ledsvo"
comment "интерлайновые копии"
agent_comment "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent_comment "3.5%"
interline :less_than_half
routes "RU..."
discount "1.75%"
ticketing_method "aviacenter"
disabled "Пока не разруливается с чистым экономом на уровне спеки: также как и с OW example в чистом правиле не сделать"
agent "5%"
subagent "3.5%"
end

rule 7 do
example "svocdg cdgsvo/ab svoled ledsvo"
agent_comment "1 рубль (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent_comment "5 коп"
interline :less_than_half
classes :economy
routes "RU..."
our_markup "20"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
end

rule 8 do
example "svocdg cdgled/ab ledsvo/ab"
example "svocdg/ab cdgsvo/ab"
no_commission
end

