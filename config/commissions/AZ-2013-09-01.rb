carrier "AZ", start_date: "2013-09-01"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "6%"
discount "6%"
agent_comment "на период 01.09.2013 года по 30.09.2013 года"
agent_comment "7% на Эконом и Бизнес классе на все направления AZ с началом путешествия только из Екатеринбурга, "
agent_comment "обязательным наличием в маршруте двух рейсов Екатеринбург Рим AZ 553 и Рим Екатеринбург AZ 552."
subagent_comment "по AZ субагентскую ставим пока 6%"
check %{ includes(city_iatas.first, "SVX") and includes(city_iatas, "ROM") }
example "svxfco fcosvx"
example "svxfco fcocdg cdgfco fcosvx"
end

rule 2 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "1.5%"
agent_comment "1 euro. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
subagent_comment "5 руб. с билета по опубл. тарифам на все остальные рейсы AZ (включая code-share);"
example "mrucdg"
example "mrucdg cdgmru"
end

rule 3 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "2%"
agent_comment "1 euro с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
subagent_comment "5 руб. с билета по опубл. тарифам на рейсы Interline, если 1-ый сегмент выполнен под кодом AZ."
interline :first
example "svocdg cdgsvo/ab"
end

rule 4 do
no_commission
example "svocdg/ab cdgsvo"
end

