carrier "ZI"

rule 1 do
ticketing_method "aviacenter"
agent "11%"
subagent "9%"
discount "15.75%"
agent_comment "11% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subagent_comment "9% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subclasses "IDJC"
example "svocdg/i"
end

rule 2 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "8.75%"
agent_comment "7% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subagent_comment "5% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subclasses "MKONXHBYSW"
example "svocdg/k"
end

rule 3 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "3.5%"
agent_comment "3% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subagent_comment "2% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subclasses "TQUVL"
example "svocdg/q"
end

rule 4 do
no_commission "проверить: Система не дает интерлайн"
ticketing_method "aviacenter"
agent "0%"
subagent "0%"
discount "2.5%"
consolidator "2%"
agent_comment "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
subagent_comment "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
interline :yes
check %{ includes_only(marketing_carrier_iatas, 'UN  ZI') }
example "cdgsvo/un"
example "cdgsvo svocdg/un"
end

