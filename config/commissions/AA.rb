carrier "AA"

rule 1 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "1.5%"
agent_comment "1% от опубл. тарифа на собственные рейсы AA, кроме:"
subagent_comment "0,5% от опубл. тарифа на собственные рейсы AA, кроме:"
example "svocdg"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "1.5%"
consolidator "2%"
agent_comment "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
subagent_comment "0% от опубл. тарифов по маршрутам из 50 штатов США (включая Пуэрто Рико/Виргинские острова (США) и Канады;"
routes "US,CA,PR,VI..."
example "miaiad"
end

rule 3 do
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "1.5%"
consolidator "2%"
agent_comment "Решили с Любой включить интерлайн, хотя он и не прописан"
subagent_comment "Решили с Любой включить интерлайн, хотя он и не прописан"
interline :unconfirmed
example "miaiad iadmia/ab"
end

rule 4 do
disabled "ни разу не попадались"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "1.5%"
consolidator "2%"
agent_comment "0% от тарифов VUSA, N1VISIT и N2VISIT."
subagent_comment "0% от тарифов VUSA, N1VISIT и N2VISIT."
end

