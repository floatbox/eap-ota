carrier "AA"

example "svocdg"
agent "1% от опубл. тарифа на собственные рейсы AA, кроме:"
subagent "0,5% от опубл. тарифа на собственные рейсы AA, кроме:"
ticketing_method "aviacenter"
commission "1%/0.5%"

example "miaiad"
agent "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
subagent "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
routes "US,CA,PR,VI..."
important!
consolidator "2%"
our_markup "0.5%"
ticketing_method "aviacenter"
commission "0%/0%"

example "miaiad iadmia/ab"
agent "Решили с Любой включить интерлайн, хотя он и не прописан"
subagent "Решили с Любой включить интерлайн, хотя он и не прописан"
interline :unconfirmed
consolidator "2%"
our_markup "0.5%"
ticketing_method "aviacenter"
commission "0%/0%"

agent "0% от тарифов VUSA, N1VISIT и N2VISIT."
subagent "0% от тарифов VUSA, N1VISIT и N2VISIT."
consolidator "2%"
ticketing_method "aviacenter"
disabled "ни разу не попадались"
commission "0%/0%"

