carrier "MU", start_date: "2011-09-15"

rule 1 do
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
discount "10.5%"
agent_comment "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 9%"
subagent_comment "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 7%"
classes :business
routes "MOW-TW,HK,MO..."
example "svohkg/business"
example "svohkg/business hkgmfm/business"
example "svotsa/business"
example "svotsa/business tsahkg/business"
example "svotpe/business"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "7.5%"
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
discount "7.5%"
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
discount "4.5%"
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
discount "1.5%"
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
discount "1.5%"
consolidator "2%"
agent_comment "Рейсы Других авиакомпаний  – 1 EUR"
subagent_comment "Рейсы Других авиакомпаний – 5 руб"
interline :absent
example "svohkg/ab"
end

