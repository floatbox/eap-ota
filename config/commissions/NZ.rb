carrier "NZ"

rule 1 do
example "svocdg cdgsvo"
agent_comment "7% от тарифа на международные перелеты на рейсы NZ;"
subagent_comment "5% от тарифа на международные перелеты на рейсы NZ;"
international
discount "5%"
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
end

rule 2 do
example "dudbhe bhedud"
agent_comment "5% от тарифа на внутренние перелеты на рейсы NZ."
subagent_comment "3,5% от тарифа на внутренние перелеты на рейсы NZ."
domestic
discount "3.5%"
ticketing_method "aviacenter"
agent "5%"
subagent "3.5%"
end

