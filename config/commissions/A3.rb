carrier "A3"

rule 1 do
example "scocdg cdgsvo"
agent_comment " 7% для тарифов Экономического класса"
subagent_comment "5% для тарифов Эконом класса"
international
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "svocdg/business cdgsvo/business"
agent_comment "9% для тарифов Бизнес класса"
subagent_comment "7% для тарифов Бизнес класса"
classes :business
important!
international
discount "7%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 3 do
example "skgath athskg/business"
agent_comment "Внутренние перелеты: 1% для тарифов Экономического и Бизнес классов"
subagent_comment "5 руб. с билета для тарифов Эконом и Бизнес классов"
classes :economy, :business
domestic
consolidator "2%"
ticketing_method "aviacenter"
agent "1%"
subagent "5"
end

rule 4 do
example "svocdg cdgsvo/ab"
agent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0"
end

