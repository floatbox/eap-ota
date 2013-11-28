carrier "TK", start_date: "2013-11-25"

rule 1 do
ticketing_method "aviacenter"
agent "17%"
subagent "15%"
discount "7.5%"
agent_comment "C 25.11.13г. по 16.03.14г. с вылетами из РФ"
agent_comment "17% от тарифа Бизнес класса на рейсы TK с вылетом из РФ"
subagent_comment "15% от тарифа Бизнес класса на рейсы TK"
classes :business
routes "RU..."
example "svoist/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "10%"
subagent "8%"
discount "4%"
agent_comment "C 25.11.13г. по 16.03.14г. с вылетами из РФ"
agent_comment "10% (8%) от полного опубл. тарифа IATA (кроме классов G,W) на рейсы TK"
agent_comment "10% (8%) от тарифа Эконом класса (кроме классов G,W) на рейсы TK"
subagent_comment "8% от полного опубл. тарифа IATA (кроме классов G,W) на рейсы TK"
subagent_comment "8% от тарифа Эконом класса (кроме классов G,W) на рейсы TK"
routes "RU..."
check %{ not includes(booking_classes, "G W") }
example "svoist istsvo"
end

rule 3 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "2.5%"
agent_comment "На все остальные даты и вылеты"
agent_comment "7% от полного опубл. тарифа IATA на рейсы TK;"
agent_comment "+ 7% от тарифа Эконом класса на рейсы TK;"
subagent_comment "5% от тарифа экономического класса на рейсы TK;"
example "istsvo svoist"
end

rule 4 do
important!
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "2.5%"
agent_comment "На все остальные даты и вылеты"
agent_comment "7% от тарифа Бизнес класса на рейсы TK с вылетом не из РФ (кроме перелетов внутри Турции);"
subagent_comment "5% от тарифа Бизнес класса на рейсы TK с вылетом не из РФ (кроме перелетов внутри Турции"
classes :business
check %{ not includes(country_iatas.first, 'RU') and not includes_only(country_iatas, 'TR') }
example "miaist/business"
end

rule 5 do
important!
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "1.5%"
agent_comment "На все остальные даты и вылеты"
agent_comment "5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
subagent_comment "3,5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
classes :business, :economy
domestic
example "istank"
example "istank/business"
end

rule 6 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "2.5%"
agent_comment "На все остальные даты и вылеты"
agent_comment "Как обычная 7% (Билеты «Интерлайн» под кодом TK могут быть выписаны только в случае существования опубл. тарифов и только при условии, если TK выполняет первый рейс)"
subagent_comment "Как обычная 5%"
interline :first
example "svoist istsvo/ab"
end

