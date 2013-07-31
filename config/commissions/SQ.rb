carrier "SQ"

example "svosin"
agent "3% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
subagent "2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
routes "RU..."
discount "0%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'RU') }
commission "3%/2%"

example "svohou houmia"
example "housvo"
agent "6% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
subagent "4,2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
important!
discount "3%"
ticketing_method "aviacenter"
check %{ (includes(country_iatas.first, 'RU') and includes(city_iatas, 'HOU')) or 
  (includes(city_iatas.first, 'HOU') and includes(country_iatas.last, 'RU')) }
commission "6%/4.2%"

example "miahou housvo"
example "sinsvo"
example "housvo svosin"
example "sinsvo svosin/su"
agent "3% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
agent "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
subagent "2% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
subagent "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
interline :no, :yes
discount "0%"
ticketing_method "aviacenter"
commission "3%/2%"

