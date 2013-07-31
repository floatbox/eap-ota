carrier "TK", start_date: "2013-03-17"

example "istsvo svoist"
agent "7% от полного опубл. тарифа IATA на рейсы TK;"
agent "+ 7% от тарифа Эконом класса на рейсы TK;"
subagent "5% от тарифа экономического класса на рейсы TK;"
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svoist/business"
agent "12% от тарифа Бизнес класса на рейсы TK с вылетом из РФ"
subagent "нет? ставлю 10%"
classes :business
routes "RU..."
important!
discount "10%"
ticketing_method "aviacenter"
commission "12%/10%"

example "miaist/business"
agent "7% от тарифа Бизнес класса на рейсы TK с вылетом не из РФ (кроме перелетов внутри Турции);"
subagent "нет? ставлю 5%"
classes :business
important!
discount "5%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas.first, 'RU') and not includes_only(country_iatas, 'TR') }
commission "7%/5%"

example "istank"
example "istank/business"
agent "5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
subagent "3,5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
classes :business, :economy
important!
domestic
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

example "svoist istsvo/ab"
agent "Как обычная 7% (Билеты «Интерлайн» под кодом TK могут быть выписаны только в случае существования опубл. тарифов и только при условии, если TK выполняет первый рейс)"
subagent "Как обычная 5%"
interline :first
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

