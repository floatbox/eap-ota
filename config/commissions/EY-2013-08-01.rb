carrier "EY", start_date: "2013-08-01"

rule 1 do
ticketing_method "aviacenter"
agent "10%"
subagent "8%"
discount "4%"
agent_comment "C 01.08.13г. по 30.09.13г. 10% от опубл. тарифов Первого и Бизнес класса на собств.рейсы EY, включая код-шеринг сегменты, выписанные на бланках EY с сегментом EY. А также на сквозные рейсы Interline с обязательным участием EY."
subagent_comment "8%"
interline :no, :yes
classes :first, :business
example "svocdg/first"
example "svocdg/first cdgsvo/business/ab"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "1.5%"
agent_comment "5% от опубл. тарифов Эконом класса на собств.рейсы EY, а также на сквозные рейсы Interline с обязательным участием EY."
subagent_comment "3.5%"
interline :no, :yes
example "svocdg"
example "svocdg cdgsvo/ab"
end

rule 3 do
not_implemented "не умеем распознавать турооператорские тарифы"
agent "5%"
subagent "3.5%"
discount "2.5%"
agent_comment "5% от опубл. туроператорских. тарифов БИЗНЕС класса на собств. рейсы EY, а также на сквозные рейсы Interline с обязательным участием EY."
subagent_comment "3.5%"
end

rule 4 do
not_implemented "не умеем распознавать веб-тарифы"
agent "3%"
subagent "1%"
agent_comment "3% от тарифа за продажи авиаперевозок на рейсы EY по веб-тарифам."
subagent_comment "1%"
end

