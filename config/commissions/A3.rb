carrier "A3"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "5%"
agent_comment " 7% для тарифов Экономического класса"
subagent_comment "5% для тарифов Эконом класса"
international
example "scocdg cdgsvo"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "7%"
agent_comment "9% для тарифов Бизнес класса"
subagent_comment "7% для тарифов Бизнес класса"
classes :business
international
example "svocdg/business cdgsvo/business"
end

rule 3 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
discount "1%"
consolidator "2%"
agent_comment "Внутренние перелеты: 1% для тарифов Экономического и Бизнес классов"
subagent_comment "5 руб. с билета для тарифов Эконом и Бизнес классов"
classes :economy, :business
domestic
example "skgath athskg/business"
end

rule 4 do
ticketing_method "aviacenter"
agent "1"
subagent "0"
discount "1%"
consolidator "2%"
agent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
example "svocdg cdgsvo/ab"
end

