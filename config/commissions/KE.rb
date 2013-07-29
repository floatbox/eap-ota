carrier "KE"

example "svogmp"
agent "С 01.04.2011г. 5% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
subagent "С 01.04.2011г. 3% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута в России."
routes "RU..."
discount "1.5%"
ticketing_method "aviacenter"
commission "5%/3%"

example "gmpsvo"
agent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
subagent "С 01.04.2011г. 0% от опубл. тарифов на собств. рейсы KE с пунктом начала маршрута вне России."
consolidator "2%"
ticketing_method "aviacenter"
check %{ not includes(country_iatas.first, 'RU') }
commission "0%/0%"

example "svoicn icnsvo/ab"
no_commission

