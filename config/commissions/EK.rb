carrier "EK"

example "svocdg/first cdgsvo/business"
example "svocdg/first cdgsvo/first"
agent "5% от тарифов Первого и Бизнес классов на рейсы EK;"
subagent "3,5% от тарифов Первого и Бизнес классов на рейсы EK;"
classes :first, :business
routes "RU..."
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg/business cdgsvo"
example "svocdg/first cdgsvo"
agent "5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
subagent "3,5% от комб. тарифов Первого и/или Бизнес класса с тарифами Эконом класса на рейсы EK;"
routes "RU..."
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg"
agent "1 руб. с билета по опубл.тарифам Эконом класса на рейсы EK."
subagent "5 коп. с билета по опубл.тарифам Эконом класса на собств. рейсы EK."
classes :economy
routes "RU..."
important!
ticketing_method "aviacenter"
commission "1/0.05"

example "jfkcdg"
agent "1 руб. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
subagent "С 01.01.13г. 5 коп. с билета по опубл.тарифам на рейсы EK с началом перевозки не в России."
ticketing_method "aviacenter"
check %{ not includes_only(country_iatas.first, 'RU') }
commission "1/0.05"

example "svocdg/business cdgsvo/ab/business svoled/business ledsvo/business"
agent "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "3.5%"
interline :less_than_half
classes :first, :business
routes "RU..."
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svocdg/first cdgsvo/ab/business svoled ledsvo"
comment "интерлайновые копии"
agent "5% (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "3.5%"
interline :less_than_half
routes "RU..."
discount "1.75%"
ticketing_method "aviacenter"
disabled "Пока не разруливается с чистым экономом на уровне спеки: также как и с OW example в чистом правиле не сделать"
commission "5%/3.5%"

example "svocdg cdgsvo/ab svoled ledsvo"
agent "1 рубль (Билеты «Интерлайн» могут быть выписаны, если на долю перевозчика приходится более 50% маршрута.)"
subagent "5 коп"
interline :less_than_half
classes :economy
routes "RU..."
our_markup "20"
ticketing_method "aviacenter"
commission "1/0.05"

example "svocdg cdgled/ab ledsvo/ab"
example "svocdg/ab cdgsvo/ab"
no_commission

