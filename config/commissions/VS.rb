carrier "VS"

example "svocdg cdgsvo"
agent "7% от опубл. тарифов на собств. рейсы VS"
subagent "5% от опубл. тарифов на собств.рейсы VS"
discount "4%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svolhr/ba lhrcce"
comment "FIXME надо ли проверять трансатлантику?"
agent "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :yes
discount "4%"
ticketing_method "aviacenter"
check %{ includes(%W(UN BA SU), marketing_carrier_iatas.first) and includes(marketing_carrier_iatas.second, 'VS') }
commission "7%/5%"

example "svocdg cdgsvo/ab"
no_commission

