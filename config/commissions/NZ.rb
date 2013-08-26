carrier "NZ"

rule 1 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "2.5%"
agent_comment "7% от тарифа на международные перелеты на рейсы NZ;"
subagent_comment "5% от тарифа на международные перелеты на рейсы NZ;"
international
example "svocdg cdgsvo"
end

rule 2 do
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
discount "1.75%"
agent_comment "5% от тарифа на внутренние перелеты на рейсы NZ."
subagent_comment "3,5% от тарифа на внутренние перелеты на рейсы NZ."
domestic
example "dudbhe bhedud"
end

