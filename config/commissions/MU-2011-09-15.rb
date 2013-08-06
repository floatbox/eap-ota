carrier "MU", start_date: "2011-09-15"

rule 1 do
example "svohkg/business"
example "svohkg/business hkgmfm/business"
example "svotsa/business"
example "svotsa/business tsahkg/business"
example "svotpe/business"
agent_comment "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 9%"
subagent_comment "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 7%"
classes :business
routes "MOW-TW,HK,MO..."
discount "7%"
ticketing_method "aviacenter"
agent "9%"
subagent "7%"
end

rule 2 do
example "ledhkg/economy"
example "ledtsa/economy"
example "ledtpe/economy"
agent_comment "MU междунар или регион-ные* рейсы Экономический  класс – 7%"
subagent_comment "MU междунар или регион-ные* рейсы Экономический класс – 5%"
classes :economy
routes "...TW,HK,MO..."
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 3 do
example "ledhkg/economy hkgled/business"
agent_comment "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 7%"
subagent_comment "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 5%"
classes :economy, :business
routes "...TK,HK,MO..."
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 4 do
example "svohkg hkgsvo/ab"
example "svomfm/ab mfmsvo"
agent_comment "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 5%"
subagent_comment "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 3%"
interline :yes
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 5 do
example "shacan"
agent_comment "MU только внутр. перелет по территории КНР – 1 EUR"
subagent_comment "MU только внутр. перелет по территории КНР – 5 руб"
domestic
consolidator "2%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

rule 6 do
example "svohkg/ab"
agent_comment "Рейсы Других авиакомпаний  – 1 EUR"
subagent_comment "Рейсы Других авиакомпаний – 5 руб"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
end

