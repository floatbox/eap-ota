carrier "A3", start_date: "2014-01-05"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
agent_comment "7% для тарифов Бизнес класса"
subagent_comment "5% для тарифов Бизнес класса"
classes :business
international
example "svocdg/business cdgsvo/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "4%"
subagent "2%"
agent_comment "4% для тарифов Экономического класса"
subagent_comment "2% для тарифов Эконом класса"
international
example "scocdg cdgsvo"
end

rule 3 do
ticketing_method "aviacenter"
agent "1%"
subagent "5"
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
subagent "0.05"
consolidator "2%"
agent_comment "1 рубль (0,05 руб+2% сбор АЦ) с тарифов по Р, G классам, IT- тарифы, а также авиабилеты, выписанные по интерлайн соглашению"
subagent_comment "1 рубль (0,05 руб+2% сбор АЦ) с тарифов по Р, G классам, IT- тарифы, а также авиабилеты, выписанные по интерлайн соглашению"
interline :yes
subclasses "PG"
example "svocdg/p cdgsvo/g/ab"
end

rule 5 do
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
consolidator "2%"
agent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
example "svocdg cdgsvo/ab"
end

