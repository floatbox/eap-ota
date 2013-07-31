carrier "MU", start_date: "2011-09-15"

example "svohkg/business"
example "svohkg/business hkgmfm/business"
example "svotsa/business"
example "svotsa/business tsahkg/business"
example "svotpe/business"
agent "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 9%"
subagent "MU междунар или регион-ные* рейсы Бизнес класс, вылет из Москвы – 7%"
classes :business
routes "MOW-TW,HK,MO..."
discount "7%"
ticketing_method "aviacenter"
commission "9%/7%"

example "ledhkg/economy"
example "ledtsa/economy"
example "ledtpe/economy"
agent "MU междунар или регион-ные* рейсы Экономический  класс – 7%"
subagent "MU междунар или регион-ные* рейсы Экономический класс – 5%"
classes :economy
routes "...TW,HK,MO..."
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "ledhkg/economy hkgled/business"
agent "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 7%"
subagent "MU междунар или регион-ные* рейсы Бизнес + Эконом класс – 5%"
classes :economy, :business
routes "...TK,HK,MO..."
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svohkg hkgsvo/ab"
example "svomfm/ab mfmsvo"
agent "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 5%"
subagent "MU междунар или регион-ные* рейсы + рейсы Других авиакомпаний на одном бланке – 3%"
interline :yes
discount "3%"
ticketing_method "aviacenter"
commission "5%/3%"

example "shacan"
agent "MU только внутр. перелет по территории КНР – 1 EUR"
subagent "MU только внутр. перелет по территории КНР – 5 руб"
domestic
consolidator "2%"
ticketing_method "aviacenter"
commission "1eur/5"

example "svohkg/ab"
agent "Рейсы Других авиакомпаний  – 1 EUR"
subagent "Рейсы Других авиакомпаний – 5 руб"
interline :absent
consolidator "2%"
ticketing_method "aviacenter"
commission "1eur/5"

