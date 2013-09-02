carrier "TK", start_date: "2013-03-17"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7% от полного опубл. тарифа IATA на рейсы TK;"
agent_comment "+ 7% от тарифа Эконом класса на рейсы TK;"
subagent_comment "5% от тарифа экономического класса на рейсы TK;"
example "istsvo svoist"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "12%"
subagent "10%"
discount "10%"
agent_comment "12% от тарифа Бизнес класса на рейсы TK с вылетом из РФ"
subagent_comment "нет? ставлю 10%"
classes :business
routes "RU..."
example "svoist/business"
end

rule 3 do
important!
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "5%"
agent_comment "7% от тарифа Бизнес класса на рейсы TK с вылетом не из РФ (кроме перелетов внутри Турции);"
subagent_comment "нет? ставлю 5%"
classes :business
check %{ not includes(country_iatas.first, 'RU') and not includes_only(country_iatas, 'TR') }
example "miaist/business"
end

rule 4 do
important!
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "3.5%"
agent_comment "5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
subagent_comment "3,5% от тарифа эконом и бизнес класса при перелетах внутри Турции на рейсы TK."
classes :business, :economy
domestic
example "istank"
example "istank/business"
end

rule 5 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "Как обычная 7% (Билеты «Интерлайн» под кодом TK могут быть выписаны только в случае существования опубл. тарифов и только при условии, если TK выполняет первый рейс)"
subagent_comment "Как обычная 5%"
interline :first
example "svoist istsvo/ab"
end

