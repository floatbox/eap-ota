carrier "KC", start_date: "2012-06-11"

example "tsekgf"
agent "С 11.06.12г. 4% от опубл. тарифа на собств. рейсы КС по маршрутам внутри Республики Казахстан;"
subagent "3% от тарифа по маршрутам внутри Республики Казахстан;"
domestic
discount "1.5%"
ticketing_method "aviacenter"
commission "4%/3%"

example "svoala alasvo"
agent "С 11.06.12г. 1 евро с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам"
subagent "С 11.06.12г. 5 руб. с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам;"
consolidator "2%"
ticketing_method "aviacenter"
commission "1eur/5"

example "svoala/ab alasvo"
agent "С 11.06.12г. 1 евро с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
subagent "С 11.06.12г. 5 руб. с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
commission "1eur/5"

example "svoala/qr alasvo/qr"
agent "С 11.06.12г. 4% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
subagent "С 11.06.12г. 3% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
interline :absent
discount "1.5%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, 'QR' ) }
commission "4%/3%"

