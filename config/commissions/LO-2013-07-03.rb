carrier "LO", start_date: "2013-07-03"

rule 1 do
ticketing_method "aviacenter"
agent "5%"
subagent "3%"
discount "4%"
agent_comment "5%(3%)(3%) с вылетом из России от опубликованных прямых и трансферных тарифов Эконом и Бизнес класса на собств. рейсы LO (кроме прямых перелетов из Санкт-Петербурга в Варшаву и из Варшавы в Санкт-Петербург), и кроме тарифов: промо и групповых: L, O, U, G; (Например: 5% от трансферного тарифа Санкт-Петербург-Варшава-Барселона);"
subagent_comment "3%"
classes :economy, :business
check %{ includes(country_iatas.first, "RU") and not includes(booking_classes, "L O U G") and 
  (
    not includes_only(city_iatas, "MOW WAW") or
    not includes_only(city_iatas, "LED WAW")
  )
}
example "svowaw/economy wawsvo/business"
example "ledwaw/business wawbcn/business"
end

rule 2 do
important!
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "3%"
agent_comment "1 евро (5 руб)(0%) для прямых перелетов из Санкт-Петербурга в Варшаву и из Варшавы в Санкт-Петербург Эконом и Бизнес класса; "
subagent_comment "5р"
classes :economy, :business
routes "LED-WAW/ALL"
example "ledwaw/economy wawled/business"
example "ledwaw/business wawled/business"
end

rule 3 do
ticketing_method "aviacenter"
agent "7%"
subagent "5%"
discount "6%"
agent_comment "7%(5%)(5%) с вылетом из России только на дальне-магистральные маршруты Бизнес класса (Z/C/D) и Премиум эконом (A/P) (собств. рейсы LO  и совм. рейсы с а/к  SU); "
subagent_comment "5%"
interline :no, :yes
subclasses "ZCDAP"
check %{ includes(country_iatas.first, 'RU') and includes_only(operating_carrier_iatas, 'LO SU') }
example "svojfk/z jfksvo/su/c"
example "svobkk/p bkksvo/su/a"
end

rule 4 do
ticketing_method "aviacenter"
agent "1%"
subagent "0.5%"
discount "3%"
agent_comment "1%(0,5%)(0%) с вылетом из России на рейсы Interline, условии наличия в билете хотя бы одного сегмента собств.рейса LO; "
subagent_comment "0.5%"
interline :yes
routes "RU..."
example "svocdg/ab cdgsvo"
end

rule 5 do
ticketing_method "aviacenter"
agent "1eur"
subagent "5"
discount "3%"
agent_comment "1 евро(5 руб)(0%) на вылеты из других стран, а также на промо, групповые (L,O,U,G), корпоративные, туроператорские, веб-тарифы и т.д."
subagent_comment "5 руб"
example "svoprg/l prgwaw/u"
end

