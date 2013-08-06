carrier "VS"

rule 1 do
example "svocdg cdgsvo"
agent_comment "7% от опубл. тарифов на собств. рейсы VS"
subagent_comment "5% от опубл. тарифов на собств.рейсы VS"
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "svolhr/ba lhrcce"
comment "FIXME надо ли проверять трансатлантику?"
agent_comment "7% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
subagent_comment "5% от опубл. тарифов на рейсы Interline (до Лондона: BD, BA, SU), выписанные на ОДНОМ бланке. Первый трансатлантический перелет на Virgin Atlantic является обязательным."
interline :yes
discount "5%"
ticketing_method "aviacenter"
check %{ includes(%W(UN BA SU), marketing_carrier_iatas.first) and includes(marketing_carrier_iatas.second, 'VS') }
agent "7%"
subagent "5%"
end

rule 3 do
example "svocdg cdgsvo/ab"
no_commission
end

