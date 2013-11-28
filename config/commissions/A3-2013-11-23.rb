carrier "A3", start_date: "2013-11-23"

rule 1 do
ticketing_method "aviacenter"
agent "15%"
subagent "13%"
discount "6.5%"
agent_comment "На период с 23.11.13 по 31.12.13г. от всех опубл. тарифов (кроме тарифов по классу P, конфиде тарифов и тарифов, опубл. на момент действия распродаж) на собственные рейсы A3 между Россией и Грецией"
agent_comment "15% для тарифов Бизнес класса"
subagent_comment "13% для тарифов Бизнес класса"
classes :business
routes "RU-GR/ALL"
check %{ not includes(booking_classes, "P") }
example "svoath/business"
example "svoath/business athsvo/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "3.5%"
agent_comment "На период с 23.11.13 по 31.12.13г. от всех опубл. тарифов (кроме тарифов по классу P, конфиде тарифов и тарифов, опубл. на момент действия распродаж) на собственные рейсы A3 между Россией и Грецией"
agent_comment "9% для тарифов Эконом класс"
subagent_comment "(7%) для тарифов Эконом класс"
routes "RU-GR/ALL"
check %{ not includes(booking_classes, "P")}
example "svoath"
example "svoath athsvo"
end

rule 3 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "3.5%"
agent_comment "9% для тарифов Бизнес класса"
subagent_comment "7% для тарифов Бизнес класса"
classes :business
international
example "svocdg/business cdgsvo/business"
end

rule 4 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "2.5%"
agent_comment " 7% для тарифов Экономического класса"
subagent_comment "5% для тарифов Эконом класса"
international
example "scocdg cdgsvo"
end

rule 5 do
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

rule 6 do
ticketing_method "aviacenter"
agent "1"
subagent "0"
consolidator "2%"
agent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent_comment "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
example "svocdg cdgsvo/ab"
end

