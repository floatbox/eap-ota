carrier "XW", start_date: "2011-10-01"

rule 1 do
example "svocdg"
agent_comment "С 01.10.11г.  5 (пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании;"
subagent_comment "С 11.04.11г. 5% от всех опубл. тарифов на собств. рейсы XW;"
ticketing_method "aviacenter"
disabled "no license"
agent "5%"
subagent "5%"
end

rule 2 do
example "svocdg cdgsvo/gw"
agent_comment "С 01.10.11г. 3 (три) % от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) - как с участием, так и без участия собственных рейсов SkyExpress Limited Company (ЗАО “Небесный Экспресс”) (XW/492);"
subagent_comment "С 11.04.11г. 3% от всех опубл. тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) – с/без участия собств. рейсов XW;"
interline :yes
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, %W[XW GW]) }
disabled "no license"
agent "3%"
subagent "3%"
end

rule 3 do
example "svopee peesvo/xf"
agent_comment "С 11.04.11г. 1 (Один) Рубль РФ от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) - как с участием, так и без участия"
subagent_comment "С 11.04.11г. 5 коп с билета по опубл. тарифам на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) – с/без участия собств. рейсов XW."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, %W[XF GW]) }
disabled "no license"
agent "1"
subagent "0.05"
end

