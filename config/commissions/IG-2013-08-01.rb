carrier "IG", start_date: "2013-08-01"

example "svocdg"
agent "С 01.08.13г. 3% от всех опубл.тарифов на собственные рейсы АК MERIDIANA FLY S.P.A. (IG/191);"
subagent "1%"
ticketing_method "aviacenter"
commission "3%/1%"

example "cdgsvo svocdg/ab"
example "cdgsvo cdgjfk jfkcdg/ab"
agent "С 01.08.13г. 3% от всех опубл.тарифов на интерлайн-перевозки. Наличие сегмента АК MERIDIANA FLY S.P.A. (IG/191) на первом участке маршрута - обязательно, либо этот сегмент должен быть самым длительным на маршруте."
subagent "1%"
interline :first, :less_than_half
ticketing_method "aviacenter"
commission "3%/1%"

