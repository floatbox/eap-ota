carrier "XW", start_date: "2011-10-01"

rule 1 do
disabled "no license"
ticketing_method "aviacenter"
agent "5%"
subagent "5%"
agent_comment "С 01.10.11г.  5 (пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании;"
subagent_comment "С 11.04.11г. 5% от всех опубл. тарифов на собств. рейсы XW;"
example "svocdg"
end

rule 2 do
disabled "no license"
ticketing_method "aviacenter"
agent "3%"
subagent "3%"
agent_comment "С 01.10.11г. 3 (три) % от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) - как с участием, так и без участия собственных рейсов SkyExpress Limited Company (ЗАО “Небесный Экспресс”) (XW/492);"
subagent_comment "С 11.04.11г. 3% от всех опубл. тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) – с/без участия собств. рейсов XW;"
interline :yes
check %{ includes_only(marketing_carrier_iatas, %W[XW GW]) }
example "svocdg cdgsvo/gw"
end

rule 3 do
disabled "no license"
ticketing_method "aviacenter"
agent "1"
subagent "0.05"
consolidator "2%"
agent_comment "С 11.04.11г. 1 (Один) Рубль РФ от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) - как с участием, так и без участия"
subagent_comment "С 11.04.11г. 5 коп с билета по опубл. тарифам на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) – с/без участия собств. рейсов XW."
interline :yes
check %{ includes_only(marketing_carrier_iatas, %W[XF GW]) }
example "svopee peesvo/xf"
end

