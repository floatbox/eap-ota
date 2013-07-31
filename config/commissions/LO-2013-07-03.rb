carrier "LO", start_date: "2013-07-03"

example "svowaw/economy wawsvo/business"
example "ledwaw/business wawbcn/business"
agent "5%(3%)(3%) с вылетом из России от опубликованных прямых и трансферных тарифов Эконом и Бизнес класса на собств. рейсы LO (кроме прямых перелетов из Санкт-Петербурга в Варшаву и из Варшавы в Санкт-Петербург), и кроме тарифов: промо и групповых: L, O, U, G; (Например: 5% от трансферного тарифа Санкт-Петербург-Варшава-Барселона);"
subagent "3%"
classes :economy, :business
discount "3%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, "RU") and not includes(booking_classes, "L O U G") and 
  (
    not includes_only(city_iatas, "MOW WAW") or
    not includes_only(city_iatas, "LED WAW")
  )
}
commission "5%/3%"

example "ledwaw/economy wawled/business"
example "ledwaw/business wawled/business"
agent "1 евро (5 руб)(0%) для прямых перелетов из Санкт-Петербурга в Варшаву и из Варшавы в Санкт-Петербург Эконом и Бизнес класса; "
subagent "5р"
classes :economy, :business
routes "LED-WAW/ALL"
important!
consolidator "2%"
ticketing_method "aviacenter"
commission "1eur/5"

example "svojfk/z jfksvo/su/c"
example "svobkk/p bkksvo/su/a"
agent "7%(5%)(5%) с вылетом из России только на дальне-магистральные маршруты Бизнес класса (Z/C/D) и Премиум эконом (A/P) (собств. рейсы LO  и совм. рейсы с а/к  SU); "
subagent "5%"
interline :no, :yes
subclasses "ZCDAP"
discount "5%"
ticketing_method "aviacenter"
check %{ includes(country_iatas.first, 'RU') and includes_only(operating_carrier_iatas, 'LO SU') }
commission "7%/5%"

example "svocdg/ab cdgsvo"
agent "1%(0,5%)(0%) с вылетом из России на рейсы Interline, условии наличия в билете хотя бы одного сегмента собств.рейса LO; "
subagent "0.5%"
interline :yes
routes "RU..."
ticketing_method "aviacenter"
commission "1%/0.5%"

example "svoprg/l prgwaw/u"
agent "1 евро(5 руб)(0%) на вылеты из других стран, а также на промо, групповые (L,O,U,G), корпоративные, туроператорские, веб-тарифы и т.д."
subagent "5 руб"
consolidator "2%"
ticketing_method "aviacenter"
commission "1eur/5"

