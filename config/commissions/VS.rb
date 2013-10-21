carrier "VS"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6.25%"
agent_comment "7% от опубл. тарифов на собств. рейсы VS"
subagent_comment "5% от опубл. тарифов на собств.рейсы VS"
example "svocdg cdgsvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6.25%"
comment "FIXME надо ли проверять трансатлантику?"
agent_comment "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent_comment "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :yes
check %{ includes(%W(UN BA SU), marketing_carrier_iatas.first) and includes(marketing_carrier_iatas.second, 'VS') }
example "svolhr/ba lhrcce"
end

rule 3 do
no_commission
example "svocdg cdgsvo/ab"
end

