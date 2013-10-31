carrier "MU", start_date: "2011-09-15"

rule 1 do
ticketing_method "aviacenter"
agent "15%"
subagent "13%"
discount "14%"
agent_comment "MU с на междунар.рейсы Бизнес класса с вылетом из Москвы (15% от тарифа классов C/J/D)"
subagent_comment "MU вылет из Москвы: междунар. или регион-ные* рейсы Бизнес класса (13% от тарифа классов C/J/D)"
subclasses "CJD"
routes "MOW..."
example "svohkg/c"
example "svohkg/j hkgmfm/d"
example "svotsa/c"
example "svotsa/j tsahkg/d"
example "svotpe/c"
end

rule 1 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "8%"
agent_comment "(9% от тарифа классa I);"
subagent_comment "(7% от тарифа классa I);"
subclasses "I"
routes "MOW..."
example "svohkg/i"
example "svohkg/i hkgmfm/i"
example "svotsa/i"
example "svotsa/i tsahkg/i"
example "svotpe/i"
end

rule 1 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "8%"
agent_comment "MU регион-ные* рейсы Бизнес класс, вылет из Москвы – 9%;"
subagent_comment ""
subclasses "I"
routes "MOW-TW,HK,MO..."
example "svohkg/i"
example "svohkg/i hkgmfm/i"
example "svotsa/i"
example "svotsa/i tsahkg/i"
example "svotpe/i"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "MU междунар или регион-ные* рейсы Экономический  класс – 7%"
subagent_comment "MU междунар или регион-ные* рейсы Экономический класс – 5%"
classes :economy
routes "...TW,HK,MO..."
example "ledhkg/economy"
example "ledtsa/economy"
example "ledtpe/economy"
end

rule 3 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 7%"
subagent_comment "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 5%"
classes :economy, :business
routes "...TK,HK,MO..."
example "ledhkg/economy hkgled/business"
end

rule 4 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 5%"
subagent_comment "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 3%"
interline :yes
example "svohkg hkgsvo/ab"
example "svomfm/ab mfmsvo"
end

rule 5 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
consolidator "2%"
agent_comment "MU только внутр. перелет по территории КНР – 1 EUR"
subagent_comment "MU только внутр. перелет по территории КНР – 5 руб"
domestic
example "shacan"
end

rule 6 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
consolidator "2%"
agent_comment "Рейсы Других авиакомпаний  – 1 EUR"
subagent_comment "Рейсы Других авиакомпаний – 5 руб"
interline :absent
example "svohkg/ab"
end

