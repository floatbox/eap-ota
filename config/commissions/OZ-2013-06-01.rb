carrier "OZ", start_date: "2013-06-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "6.5%"
agent_comment "5% (3%)(3%) от опубл.тарифов на собств.рейсы OZ; "
subagent_comment "3%"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "6.5%"
agent_comment "5% (3%)(3%) от опубл.тарифов на рейсы Interline с обязательным собств. сегментом OZ;"
subagent_comment "3%"
interline :yes
example "svocdg cdgsvo/ab"
end

