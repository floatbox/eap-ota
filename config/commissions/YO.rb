carrier "YO"

rule 1 do
example "svocdg"
agent_comment "1 руб. с билета на все виды тарифов (В договоре Interline не прописан.)"
subagent_comment "50 коп. с билета на рейсы YO"
interline :no, :unconfirmed
consolidator "2%"
ticketing_method "aviacenter"
agent "1"
subagent "0.5"
end

