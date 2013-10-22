carrier "EK"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "6.13%"
agent_comment "5% от тарифов Первого и Бизнес классов на рейсы EK;"
subagent_comment "3,5% от тарифов Первого и Бизнес классов на рейсы EK;"
classes :first, :business
routes "RU..."
example "svocdg/first cdgsvo/business"
example "svocdg/first cdgsvo/first"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "6.13%"
agent_comment "5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
subagent_comment "3,5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
routes "RU..."
example "svocdg/business cdgsvo"
example "svocdg/first cdgsvo"
end

rule 3 do
important!
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2.5%"
agent_comment "1 руб. с билета по опубл.тарифам Эконом класса на рейсы EK."
subagent_comment "5 коп. с билета по опубл.тарифам Эконом класса на собств. рейсы EK."
classes :economy
routes "RU..."
example "svocdg"
end

rule 4 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2.5%"
agent_comment "1 руб. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
subagent_comment "С 01.01.13г. 5 коп. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
check %{ not includes_only(country_iatas.first, 'RU') }
example "jfkcdg"
end

rule 5 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "6.13%"
agent_comment "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent_comment "3.5%"
interline :less_than_half
classes :first, :business
routes "RU..."
example "svocdg/business cdgsvo/ab/business svoled/business ledsvo/business"
end

rule 6 do
not_implemented "Пока не разруливается с чистым экономом на уровне спеки: также как и с OW example в чистом правиле не сделать"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "6.13%"
comment "интерлайновые копии"
agent_comment "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent_comment "3.5%"
interline :less_than_half
routes "RU..."
example "svocdg/first cdgsvo/ab/business svoled ledsvo"
end

rule 7 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
discount "2.5%"
agent_comment "1 рубль (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent_comment "5 коп"
interline :less_than_half
classes :economy
routes "RU..."
example "svocdg cdgsvo/ab svoled ledsvo"
end

rule 8 do
no_commission
example "svocdg cdgled/ab ledsvo/ab"
example "svocdg/ab cdgsvo/ab"
end

