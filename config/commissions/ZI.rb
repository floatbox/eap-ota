carrier "ZI"

example "svocdg/i"
agent "11% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subagent "9% от тарифа на собств. рейсы ZI по классам бронирования I/D/J/C;"
subclasses "IDJC"
discount "9%"
ticketing_method "aviacenter"
commission "11%/9%"

example "svocdg/k"
agent "7% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subagent "5% от тарифа на собств. рейсы ZI по классам бронирования M/K/O/N/X/H/B/Y/S/W;"
subclasses "MKONXHBYSW"
discount "5%"
ticketing_method "aviacenter"
commission "7%/5%"

example "svocdg/q"
agent "3% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subagent "2% от тарифа на собств. рейсы ZI по классам бронирования T/Q/U/V/L"
subclasses "TQUVL"
discount "2%"
ticketing_method "aviacenter"
commission "3%/2%"

example "cdgsvo/un"
example "cdgsvo svocdg/un"
agent "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
subagent "0% от тарифа на рейсы Interline (разрешен только с авиакомпанией Трансаэро (UN)."
interline :yes
consolidator "2%"
ticketing_method "aviacenter"
check %{ includes_only(marketing_carrier_iatas, 'UN  ZI') }
disabled "Система не дает интерлайн"
commission "0%/0%"

