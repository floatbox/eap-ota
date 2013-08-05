carrier "EY", start_date: "2013-08-01"

example "svocdg/first"
example "svocdg/first cdgsvo/business/ab"
agent "C 01.08.13г. по 30.09.13г. 10% от опубл. тарифов Первого и Бизнес класса на собств.рейсы EY, включая код-шеринг сегменты, выписанные на бланках EY с сегментом EY. А также на сквозные рейсы Interline с обязательным участием EY."
subagent "8%"
interline :no, :yes
classes :first, :business
discount "8%"
ticketing_method "aviacenter"
commission "10%/8%"

example "svocdg"
example "svocdg cdgsvo/ab"
agent "5% от опубл. тарифов Эконом класса на собств.рейсы EY, а также на сквозные рейсы Interline с обязательным участием EY."
subagent "3.5%"
interline :no, :yes
discount "3.5%"
ticketing_method "aviacenter"
commission "5%/3.5%"

agent "5% от опубл. туроператорских. тарифов БИЗНЕС класса на собств. рейсы EY, а также на сквозные рейсы Interline с обязательным участием EY."
subagent "3.5%"
discount "2.5%"
not_implemented "не умеем распознавать турооператорские тарифы"
commission "5%/3.5%"

agent "3% от тарифа за продажи авиаперевозок на рейсы EY по веб-тарифам."
subagent "1%"
not_implemented "не умеем распознавать веб-тарифы"
commission "3%/1%"

