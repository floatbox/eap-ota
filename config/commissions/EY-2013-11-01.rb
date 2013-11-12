carrier "EY", start_date: "2013-11-01"

rule 1 do
ticketing_method "aviacenter"
agent "10%"
subagent "8%"
discount "3.5%"
agent_comment "по 31.12.13г. 10% (8%) от опубл. тарифов Первого и Бизнес класса на собств.рейсы EY, включая код-шеринг сегменты, выписанные на бланках EY с сегментом EY. А также на сквозные рейсы Interline с обязательным участием EY."
interline :no, :yes
classes :first, :business
example "svocdg/first cdgsvo/first"
example "svocdg/business"
example "svocdg/ab/business cdgsvo/first"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "3.5%"
agent_comment "5% (3%) от опубл. тарифов Эконом класса на собств.рейсы EY, а также на сквозные рейсы Interline с обязательным участием EY."
interline :no, :yes
example "svocdg"
example "svocdg/ab cdgsvo"
end

