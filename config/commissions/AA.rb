carrier "AA"

rule 1 do
example "svocdg"
agent_comment "1% от опубл. тарифа на собственные рейсы AA, кроме:"
subagent_comment "0,5% от опубл. тарифа на собственные рейсы AA, кроме:"
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
end

rule 2 do
example "miaiad"
agent_comment "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
subagent_comment "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
routes "US,CA,PR,VI..."
important!
consolidator "2%"
our_markup "0.5%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 3 do
example "miaiad iadmia/ab"
agent_comment "Решили с Любой включить интерлайн, хотя он и не прописан"
subagent_comment "Решили с Любой включить интерлайн, хотя он и не прописан"
interline :unconfirmed
consolidator "2%"
our_markup "0.5%"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
end

rule 4 do
agent_comment "0% от тарифов VUSA, N1VISIT и N2VISIT."
subagent_comment "0% от тарифов VUSA, N1VISIT и N2VISIT."
consolidator "2%"
ticketing_method "aviacenter"
disabled "ни разу не попадались"
agent "0%"
subagent "0%"
end

