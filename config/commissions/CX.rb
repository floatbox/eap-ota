carrier "CX"

rule 1 do
example "svocdg"
example "svocdg cdgsvo/ab"
agent_comment "7% от всех опубликованных и специальных тарифов"
subagent_comment "5% от опубликованных тарифов на рейсы CX. 50 коп с билета по туроператорским   тарифам на собств. рейсы СХ (наличие ваучера обязательно)."
interline :no, :yes
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

