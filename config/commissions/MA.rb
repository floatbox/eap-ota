carrier "MA"

rule 1 do
disabled "no subagent"
ticketing_method "aviacenter"
agent "12%"
subagent "0%"
our_markup "1%"
agent_comment "12% от тарифа по классам J,C,D,I,Y,B;"
subclasses "JCDIYB"
example "svobud/c budsvo/c"
end

rule 2 do
disabled "no subagent"
ticketing_method "aviacenter"
agent "6%"
subagent "0%"
our_markup "1%"
agent_comment "6% от тарифа по классам K,M,L,V,S,Z, N."
subclasses "KMLVSZN"
example "svobud/k budsvo/k"
end

rule 3 do
disabled "ибо обанкротились (Люба сказала)"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
our_markup "1%"
agent_comment "1 руб. с билета от опубл., конфиде.тарифов Эконом и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
subagent_comment "5 коп. с билета от опубл., конфиде.тарифов Экономического и Бизнес класса и при комбинации классов; от опубл.тарифа в случае применения совместного тарифа авиакомпаний при условии, что не менее 50 процентов маршрута должно быть закрыто на авиакомпанию МАЛЕВ (запрещается оформлять перевозку на билетах Авиакомпании без хотя бы одного участка Авиакомпании)"
interline :half
example "svobud budsvo/ab"
end

