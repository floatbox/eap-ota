carrier "OZ", start_date: "2013-06-01"

example "svocdg"
agent "5% (3%)(3%) от опубл.тарифов на собств.рейсы OZ; "
subagent "3%"
discount "3%"
ticketing_method "aviacenter"
commission "5%/3%"

example "svocdg cdgsvo/ab"
agent "5% (3%)(3%) от опубл.тарифов на рейсы Interline с обязательным собств. сегментом OZ;"
subagent "3%"
interline :yes
discount "3%"
ticketing_method "aviacenter"
commission "5%/3%"

