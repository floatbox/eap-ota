carrier "A9"

example "tbsdme"
agent "8 (восемь) % от опубл. тарифа на собств. рейсы авиакомпании А9;"
subagent "6 % от опубл. тарифа на собств. рейсы А9;"
discount "3%"
ticketing_method "aviacenter"
commission "8%/6%"

example "tbsdme dmetbs/ab"
agent "7 (семь)  % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании  А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение;"
subagent "5 % от опубл. тарифа по маршрутам со сквозными тарифами, включающими участок авиакомпании А9 и авиакомпаний, с которыми А9 имеет Интерлайн-Соглашение"
interline :yes
discount "2.5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "dmetbs/ab"
agent "5 (пять)   % от опубл. тарифа на рейсы Interline без участка А9."
subagent "3 % от опубл. тарифа на рейсы Interline без участка А9."
interline :absent
discount "1.5%"
ticketing_method "aviacenter"
commission "5%/3%"

