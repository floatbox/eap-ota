carrier "LA"

example "svocdg"
agent "1 руб. с билета по опубл. тарифам на собств. рейсы LA"
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0.05"

example "svocdg/ab cdgsvo"
agent "1 руб. с билета по опубл. тарифам на рейсы Interline c участком LA. Interline под кодом LA может быть выписан только при условии, что LA выполняет как минимум один рейс. За несоблюдение данного условия будет начислен штраф в размере EUR200."
agent "Оформление отдельного авиабилета на рейсы других перевозчиков в пределах региона Южная и Центральная Америка на электронном стоке  LA ВОЗМОЖНО при условии, что внешний участок, т.е. межконтинентальный перелет, осуществляется авиакомпанией LAN. При выписке разными бланками внешнего и внутренних перелетов, все сегменты должны фигурировать в одном бронировании."
agent "Также необходимо проверять наличие MITA и BITA соглашений. В других случаях оформление авиабилетов по интерлайн соглашению на электронном стоке авиакомпании LAN Airlines (045) не разрешено."
agent "Комиссия при оформлении авиабилетов по Interline на электронном стоке авиакомпании LAN Airlines (045) во всех случаях составляет 1 руб. Авиакомпания вправе начислить штраф (ADM) за нарушение правил оформленная билета, неверную калькуляцию и т.п."
subagent "5 коп. с билета по опубл. тарифам на рейсы LA"
interline :no, :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1/0.05"
