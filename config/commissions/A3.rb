carrier "A3"

example "scocdg cdgsvo"
agent " 7% для тарифов Экономического класса"
subagent "5% для тарифов Эконом класса"
international
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svocdg/business cdgsvo/business"
agent "9% для тарифов Бизнес класса"
subagent "7% для тарифов Бизнес класса"
classes :business
important!
international
discount "7%"
ticketing_method "aviacenter"
commission "9%/7%"

example "skgath athskg/business"
agent "Внутренние перелеты: 1% для тарифов Экономического и Бизнес классов"
subagent "5 руб. с билета для тарифов Эконом и Бизнес классов"
classes :economy, :business
domestic
consolidator "2%"
ticketing_method "aviacenter"
commission "1%/5"

example "svocdg cdgsvo/ab"
agent "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
subagent "Билеты по интерлайн соглашению могут быть выписаны только при условии наличия сегментов Авиакопании."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0"

