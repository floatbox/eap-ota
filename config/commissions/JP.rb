carrier "JP"

rule 1 do
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
discount "3% + 0.5"
consolidator "2%"
agent_comment "1 руб. с билета на рейсы JP (В договоре Interline не прописан.)"
subagent_comment "50 коп. с билета на рейсы JP"
example "svocdg"
end

rule 2 do
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
discount "3% + 0.5"
consolidator "2%"
agent_comment "1р Interline не прописан"
subagent_comment "0р Interline не прописан"
interline :unconfirmed
example "cdgsvo svocdg/ab"
end

