carrier "FJ"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4.5%"
agent_comment "5% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на короткие расстояния,"
agent_comment "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
subagent_comment "3% от всех опубл.тарифов на собств. рейсы FJ для перевозки на короткие расстояния,"
subagent_comment "Перевозки на короткие расстояния: Между Fiji & Pacific Islands, AU, NZ"
interline :no, :yes
routes "FJ-FJ,AU,NZ,KI,MH,FM,NR,PH,WS,SB,TO,TV,VU,CK,AS,PF,GU,NC,NU,NF,MP,PW/ALL"
example "TVUNAN/L NANVLI/Q"
example "suvakl aklsuv/ab"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6.5%"
agent_comment "7% от всех опубл.тарифов на собств. рейсы авиакомпании для перевозки на дальние расстояния,"
agent_comment "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
subagent_comment "5% от всех опубл.тарифов на собств. рейсы FJ для перевозки на дальние расстояния,"
subagent_comment "Перевозки на дальние расстояния: Между Fiji & всеми другими пунктами назначения маршрутной сети авиакомпании FJ."
interline :no, :yes
example "suvcdg"
example "suvcdg cdgsuv/ab"
end

