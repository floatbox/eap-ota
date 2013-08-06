carrier "KC", start_date: "2012-06-11"

rule 1 do
example "tsekgf"
agent_comment "С 11.06.12г. 4% от опубл. тарифа на собств. рейсы КС по маршрутам внутри Республики Казахстан;"
subagent_comment "3% от тарифа по маршрутам внутри Республики Казахстан;"
domestic
discount "3%"
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
end

rule 2 do
example "svoala alasvo"
agent_comment "С 11.06.12г. 1 евро с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам"
subagent_comment "С 11.06.12г. 5 руб. с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам;"
consolidator "2%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 3 do
example "svoala/ab alasvo"
agent_comment "С 11.06.12г. 1 евро с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
subagent_comment "С 11.06.12г. 5 руб. с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 4 do
example "svoala/qr alasvo/qr"
agent_comment "С 11.06.12г. 4% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
subagent_comment "С 11.06.12г. 3% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
interline :absent
discount "3%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, 'QR' ) }
agent "4%"
subagent "3%"
end

