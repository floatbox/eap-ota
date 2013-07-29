carrier "XW", start_date: "2011-10-01"

example "svocdg"
agent "С 01.10.11г.  5 (пять) % от всех опубликованных тарифов на собственные рейсы авиакомпании;"
subagent "С 11.04.11г. 5% от всех опубл. тарифов на собств. рейсы XW;"
ticketing_method "aviacenter"
disabled "no license"
commission "5%/5%"

example "svocdg cdgsvo/gw"
agent "С 01.10.11г. 3 (три) % от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) - как с участием, так и без участия собственных рейсов SkyExpress Limited Company (ЗАО “Небесный Экспресс”) (XW/492);"
subagent "С 11.04.11г. 3% от всех опубл. тарифов на рейсы интерлайн-партнера - авиакомпании AIR LINES OF KUBAN (GW/113) – с/без участия собств. рейсов XW;"
interline :yes
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, %W[XW GW]) }
disabled "no license"
commission "3%/3%"

example "svopee peesvo/xf"
agent "С 11.04.11г. 1 (Один) Рубль РФ от всех опубликованных тарифов на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) - как с участием, так и без участия"
subagent "С 11.04.11г. 5 коп с билета по опубл. тарифам на рейсы интерлайн-партнера - авиакомпании VLADIVOSTOK AIR (XF/277) – с/без участия собств. рейсов XW."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, %W[XF GW]) }
disabled "no license"
commission "1/0.05"

