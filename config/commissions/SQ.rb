carrier "SQ"

rule 1 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "0%"
agent_comment "3% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
subagent_comment "2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ;"
routes "RU..."
check %{ includes(country_iatas.first, 'RU') }
example "svosin"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "6%"
subagent "4.2%"
discount "3%"
agent_comment "6% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
subagent_comment "4,2% от опубл.тарифов (вкл.промотарифы в V и Q классах) на собств.рейсы SQ/Silk Air с началом от пунктов РФ в/через Хьюстон (США) и от Хьюстона (США) в пункты РФ;"
check %{ (includes(country_iatas.first, 'RU') and includes(city_iatas, 'HOU')) or 
  (includes(city_iatas.first, 'HOU') and includes(country_iatas.last, 'RU')) }
example "svohou houmia"
example "housvo"
end

rule 3 do
ticketing_method "aviacenter"
agent "3%"
subagent "2%"
discount "0%"
agent_comment "3% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
agent_comment "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
subagent_comment "2% от опубл.тарифов на собств.рейсы SQ/Silk Air с началом от пунктов, не указанных выше;"
subagent_comment "При продаже перевозок по Interline комиссионное вознаграждение начисляется в полном объеме, если перевозка включает хотя бы один полетный сегмент SQ/Silk Air и оформлена на бланке SQ/618. Оформление перевозки на бланках SQ/618 по маршруту, который не включает хотя бы один полетный сегмент, выполняемый SQ/Silk Air, запрещено."
interline :no, :yes
example "miahou housvo"
example "sinsvo"
example "housvo svosin"
example "sinsvo svosin/su"
end

