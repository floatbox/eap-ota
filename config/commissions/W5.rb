carrier "W5"

rule 1 do
disabled "starting from 13 OCT 2011 Mahan Air (W5/537) is suspended from BSP."
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
agent_comment "5 % от всех опубликованных тарифов; (Interline отдельно не прописан)"
subagent_comment "3% от всех опубл.тарифов на собств. рейсы W5"
interline :no, :unconfirmed
example "svocdg"
end

