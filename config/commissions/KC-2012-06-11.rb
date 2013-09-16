carrier "KC", start_date: "2012-06-11"

rule 1 do
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
discount "5.25%"
agent_comment "С 11.06.12г. 4% от опубл. тарифа на собств. рейсы КС по маршрутам внутри Республики Казахстан;"
subagent_comment "3% от тарифа по маршрутам внутри Республики Казахстан;"
domestic
example "tsekgf"
end

rule 2 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "3.25%"
consolidator "2%"
agent_comment "С 11.06.12г. 1 евро с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам"
subagent_comment "С 11.06.12г. 5 руб. с билета по опубл. тарифа на собств. рейсы КС по всем международным маршрутам;"
example "svoala alasvo"
end

rule 3 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "3.25%"
consolidator "2%"
agent_comment "С 11.06.12г. 1 евро с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
subagent_comment "С 11.06.12г. 5 руб. с билета по опубл. тарифа на рейсы Interline c наличием сегмента КС;"
interline :yes
example "svoala/ab alasvo"
end

rule 4 do
ticketing_method "aviacenter"
agent "4%"
subagent "3%"
discount "5.25%"
agent_comment "С 11.06.12г. 4% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
subagent_comment "С 11.06.12г. 3% от опубл. тарифа на рейсы Interline БЕЗ сегмента КС разрешается только на Qatar Airways (QR)."
interline :absent
check %{ includes_only(marketing_carrier_iatas, 'QR' ) }
example "svoala/qr alasvo/qr"
end

