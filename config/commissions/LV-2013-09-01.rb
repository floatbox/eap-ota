carrier "LV", start_date: "2013-09-01"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "4.75%"
agent_comment "5% от опубл. тарифов Эконом класса;"
subagent_comment "3.5% от опубл. тарифов Эконом класса;"
example "svocdg"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "4.75%"
agent_comment "5% от опубл. тарифов J, Z, A;"
subagent_comment "3.5% от опубл. тарифов J, Z, A;"
subclasses "JZA"
example "svocdg/j"
example "svocdg/a"
end

rule 3 do
important!
ticketing_method "aviacenter"
agent "9.7%"
subagent "6.7%"
discount "7.95%"
agent_comment "9.7% от опубл. тарифов F, C, I, D."
subagent_comment "6.7% от опубл. тарифов F, C, I, D."
subclasses "FCID"
example "svocdg/f"
example "svocdg/c"
end

