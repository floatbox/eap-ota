carrier "OZ", start_date: "2013-06-01"

rule 1 do
example "svocdg"
agent_comment "5% (3%)(3%) от опубл.тарифов на собств.рейсы OZ; "
subagent_comment "3%"
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

rule 2 do
example "svocdg cdgsvo/ab"
agent_comment "5% (3%)(3%) от опубл.тарифов на рейсы Interline с обязательным собств. сегментом OZ;"
subagent_comment "3%"
interline :yes
discount "3%"
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
end

