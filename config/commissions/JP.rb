carrier "JP"

rule 1 do
example "svocdg"
agent_comment "1 руб. с билета на рейсы JP (В договоре Interline не прописан.)"
subagent_comment "50 коп. с билета на рейсы JP"
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
end

rule 2 do
example "cdgsvo svocdg/ab"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
end

