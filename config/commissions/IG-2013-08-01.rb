carrier "IG", start_date: "2013-08-01"

rule 1 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "1.4%"
agent_comment "С 01.08.13г. 3% от всех опубл.тарифов на собственные рейсы АК MERIDIANA FLY S.P.A. (IG/191);"
subagent_comment "1%"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "1.4%"
agent_comment "С 01.08.13г. 3% от всех опубл.тарифов на интерлайн-перевозки. Наличие сегмента АК MERIDIANA FLY S.P.A. (IG/191) на первом участке маршрута - обязательно, либо этот сегмент должен быть самым длительным на маршруте."
subagent_comment "1%"
interline :first, :less_than_half
example "cdgsvo svocdg/ab"
example "cdgsvo cdgjfk jfkcdg/ab"
end

