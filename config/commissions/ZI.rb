carrier "ZI"

rule 1 do
example "svocdg/i"
agent_comment "11% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subagent_comment "9% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subclasses "IDJC"
discount "9%"
ticketing_method "aviacenter"
agent "11%"
subagent "9%"
end

rule 2 do
example "svocdg/k"
agent_comment "7% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subagent_comment "5% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subclasses "MKONXHBYSW"
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 3 do
example "svocdg/q"
agent_comment "3% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subagent_comment "2% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subclasses "TQUVL"
discount "2%"
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
end

rule 4 do
example "cdgsvo/un"
example "cdgsvo svocdg/un"
agent_comment "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
subagent_comment "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, 'UN  ZI') }
disabled "Система не дает интерлайн"
agent "0%"
subagent "0%"
end

