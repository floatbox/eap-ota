carrier "A9"

rule 1 do
example "tbsdme"
agent_comment "8 (восемь) % от опубл. тарифа на собств. рейсы авиакомпании А9;"
subagent_comment "6 % от опубл. тарифа на собств. рейсы А9;"
discount "5%"
ticketing_method "aviacenter"
agent "8%"
subagent "6%"
end

rule 2 do
example "tbsdme dmetbs/ab"
agent_comment "7 (семь)  % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании  А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение;"
subagent_comment "5 % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение"
interline :yes
discount "4%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 3 do
example "dmetbs/ab"
agent_comment "5 (пять)   % от опубл. тарифа на рейсы Interline без участка А9."
subagent_comment "3 % от опубл. тарифа на рейсы Interline без участка А9."
interline :absent
discount "2.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

