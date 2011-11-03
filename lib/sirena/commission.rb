# encoding: utf-8
class Sirena::Commission
  include KeyValueInit
  cattr_accessor :commissions, :opts
  self.commissions = {}
  self.opts = {}

  attr_accessor :carrier, :twopcnt, :carrier_name, :doc, :code, :consolidator, :subagent,
    :interline, :subclasses, :routes, :expire, :fares, :directions,
    :discount # совместимость с амадеусовскими

  class << self
    [:doc, :code, :consolidator, :interline, :subclasses,
     :routes, :expire, :fares, :directions, :expire].each{|method_name|
      self.class_eval do
        define_method method_name.to_s do |value|
          opts[method_name] = value
        end
      end
    }

    def carrier iata, name = nil
      self.opts = {:carrier => iata, :carrier_name => name, :doc => opts[:doc]}
    end

    def subagent value
      opts[:subagent] = value
      commissions[opts[:carrier]] ||= []
      commissions[opts[:carrier]] << new(opts)
      self.opts = {:carrier=>opts[:carrier], 
        :carrier_name=>opts[:carrier_name], :doc => opts[:doc]}
    end

    def find_for(recommendation)
      twopcnt = %W[OS 3Р РЛ QW РГ МА XF ПМ J2 ЭВ EK ТИ 5H ГЛ]
      new(
        :carrier => recommendation.validating_carrier_iata,
        :twopcnt => (twopcnt.include?(recommendation.validating_carrier.iata) ||
                    twopcnt.include?(recommendation.validating_carrier.iata_ru))
      )
    end
  end

  def consolidator_markup(fare, tickets=1)
    blank_cost = 50
    if twopcnt
      fare * 0.02 + blank_cost * tickets
    else
      blank_cost * tickets
    end
  end

  # ВРЕМЕННОЕ РЕШЕНИЕ
  def share(fare, tickets=1)
    0
  end

  def discount_amount(fare, tickets=1)
    0
  end

  def agent; '0' end
  def subagent; '0' end
  def agent_comments; '' end
  def subagent_comments; '' end

doc "1.2. На БСО ЗАО «Транспортная Клиринговая Палата»:
    1.2.1. При продаже и оформлении авиаперевозок на БСО и электронных билетах
    СПД НСАВ – ТКП Агент устанавливает целевой сервисный сбор за каждый проданный
    Субагентом авиабилет в размере 50 (пятьдесят) рублей. При добровольном и
    вынужденном возврате авиабилетов этот сбор Субагенту возвращается.
    1.2.2. При продаже и оформлении авиаперевозок на БСО и электронных билетах
    СПД НСАВ – ТКП комиссионное вознаграждение Субагента составит 4 (четыре) %
    от тарифа на все авиакомпании входящие в ТКП, кроме:  "
subagent "4%"


doc "1.2.4. При продаже и оформлении авиаперевозок с формой оплаты НАЛ и
    с расчетным кодом 03С комиссионное вознаграждение Субагента
    составит 1 (один) % от тарифа."
code "03С"
subagent "1%"

doc "1.2.5. При продаже перевозок на рейсы AUSTRIAN AIRLINES (код OS):
    - комиссионное вознаграждение Субагента составит 5 (пять) рублей с билета на все рейсы;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "OS", "AUSTRIAN AIRLINES"
consolidator "2%"
subagent "5"

doc "1.2.6. При продаже перевозок с формой оплаты НАЛ и РТА на рейсы ОАО «Авиакомпания «Московия» (код 3Р):
    - комиссионное вознаграждение Субагента составит 5 (пять) рублей с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "3Р", "ОАО «Авиакомпания «Московия»"
consolidator "2%"
subagent "5"

doc "1.2.7. При продаже авиаперевозок на рейсы авиакомпании ОАО «АВИАЦИОННАЯ КОМПАНИЯ «ТРАНСАЭРО»
    (код УН) с расчетным кодом 670 (кроме перевозок по интерлайн-соглашениям) на рейсы «УН»,
    а также с расчетным кодом 99А на рейсы «УН» комиссионное вознаграждение Субагента составит:
    - с формой оплаты НАЛ и кодами подклассов: F, J, C, D (латиница); П, И, Б, Д (кириллица) 9 (девять) % от тарифа;
    - с формой оплаты НАЛ и кодами подклассов: Y, H, M, Q, B, K, O, R, E (латиница); Э, Ц, М, Я, Ж, К (кириллица) 5 (пять) % от тарифа;
    - с формой оплаты НАЛ и кодами подклассов: L, V, X, T, N, I, W (латиница); Л, В, Х, Т, Н, Ы, Ю (кириллица) 1 (один) % от тарифа;
    
    update от  11 апреля 2011г. : 
      1.4.3. 2 (два) % от тарифа на по всем тарифам классов L, V, X, T, N, I, G, W, U.
    end update

    - 5  (Пять) % от тарифа  на период с 22.03.2011г. по 31.10.2011г. с формой оплаты НАЛ,
      кодом подкласса:N (латиница);Н (кириллица) и с кодами тарифов  NSOCCDOW%, NSOCZZOW%
      по маршрутам: АНЫ-МОВ; МОВ-АНЫ; БГЩ-МОВ; МОВ-БГЩ; ВВО-МОВ; МОВ-ВВО; ВВО-СПТ; СПТ-ВВО; МДН-МОВ;
      МОВ-МДН; ПРЛ-МОВ; МОВ-ПРЛ; ПРЛ-СПТ; СПТ-ПРЛ; ХБР-МОВ; МОВ-ХБР; ХБР-СПТ; СПТ-ХБР;УЛЭ-МОВ;
      МОВ-УЛЭ; ЮЖХ-МОВ; МОВ-ЮЖХ; ЮЖХ-СПТ; СПТ-ЮЖХ; ЯКТ-МОВ; МОВ-ЯКТ
    - с формой оплаты РТА комиссионное вознаграждение Субагента не выплачивается."
carrier "УН", "ОАО «АВИАЦИОННАЯ КОМПАНИЯ «ТРАНСАЭРО»"
code "670 99А"
interline false
subclasses "F, J, C, D, П, И, Б, Д"
subagent "9%"

code "670 99А"
interline false
subclasses "Y, H, M, Q, B, K,  O, R, E, Э, Ц, М, Я, Ж, К"
subagent "5%"

code "670 99А"
interline false
subclasses "L, V, X, T, N, I, G, W, U, Л, В, Х, Т, Н, Ы, Ю"
subagent "1%"

code "670 99А"
interline false
subclasses "N, Н"
routes "АНЫ-МОВ; МОВ-АНЫ; БГЩ-МОВ; МОВ-БГЩ; ВВО-МОВ; МОВ-ВВО; ВВО-СПТ; СПТ-ВВО; МДН-МОВ;
  МОВ-МДН; ПРЛ-МОВ; МОВ-ПРЛ; ПРЛ-СПТ; СПТ-ПРЛ; ХБР-МОВ; МОВ-ХБР; ХБР-СПТ; СПТ-ХБР;УЛЭ-МОВ;
  МОВ-УЛЭ; ЮЖХ-МОВ; МОВ-ЮЖХ; ЮЖХ-СПТ; СПТ-ЮЖХ; ЯКТ-МОВ; МОВ-ЯКТ"
fares "NSOCCDOW%, NSOCZZOW%"
expire "31.10.2011"
subagent "5%"

doc "1.2.9. При продаже авиаперевозок на рейсы авиакомпании ООО «Авиакомпания «Регион-Авиа» (РЛ, расчетный код 88А):
    - комиссионное вознаграждение Субагента составит 5 (пять) рублей с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "РЛ", "ООО «Авиакомпания «Регион-Авиа»"
code "88А"
consolidator "2%"
subagent "5"

doc "1.2.10. При продаже авиаперевозок на рейсы авиакомпании BLUE WINGS AG (код QW) с формой оплаты НАЛ, БЕЗНАЛ, PTA:
    - комиссионное вознаграждение Субагента составит 5 (пять) рублей с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "QW", "BLUE WINGS AG"
consolidator "2%"
subagent "5"

doc "1.2.11. При продаже авиаперевозок на рейсы авиакомпании ООО ПКФ «Катэкавиа»
    (код КЮ) с расчетным кодом 27А (кроме перевозок по интерлайн-соглашениям)
    на рейсы «КЮ», а также с расчетным кодом 99А на рейсы «КЮ» комиссионное
    вознаграждение Субагента составит 1 (один) % от тарифа."
carrier "КЮ", "ООО ПКФ «Катэкавиа»"
code "27А 99А"
interline false
subagent "1%"

doc "1.2.13. При продаже авиаперевозок по маршрутам: МОВ-КГН, КГН-МОВ, МОВ-КГН-МОВ,
    КГН-МОВ-КГН, МОВ-ЭЛИ, ЭЛИ-МОВ, МОВ-ЭЛИ-МОВ, ЭЛИ-МОВ-ЭЛИ с формой оплаты НАЛ и
    РТА на рейсы авиакомпании ООО «РУСЛАЙН» (код РГ) с расчетным кодом 42А (включая
    перевозки по всем интерлайн-соглашениям) на рейсы «РГ», а также с расчетным
    кодом 99А на рейсы «РГ»:
    - комиссионное вознаграждение Субагента составит 50 (пятьдесят) копеек с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "РГ", "ООО «РУСЛАЙН»"
code "42А 99А"
interline true
routes "МОВ-КГН, КГН-МОВ, МОВ-КГН-МОВ, КГН-МОВ-КГН, МОВ-ЭЛИ, ЭЛИ-МОВ, МОВ-ЭЛИ-МОВ, ЭЛИ-МОВ-ЭЛИ"
consolidator "2%"
subagent "0.5"

doc "1.2.14. При продаже авиаперевозок с формой оплаты НАЛ и РТА на рейсы
    авиакомпании MALEV HUNGARIAN AIRLINES LTD (код МА) с расчетным кодом 182
    (кроме перевозок по интерлайн-соглашениям) на рейсы «МА»:
    - комиссионное вознаграждение Субагента составит 50 (пятьдесят) копеек с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "MА", "MALEV HUNGARIAN AIRLINES LTD"
code "182"
interline false
consolidator "2%"
subagent "0.5"

doc "от 1.05.2011
    1. На период с 01.05.2011г. по 31.12.2011г. при продаже с формой оплаты НАЛ и РТА
    на ЕТ и БСО НСАВ ТКП на рейсы авиакомпании ОАО «Владивосток Авиа» (код «ДД»)
    с расчетным кодом 277 (кроме перевозок по интерлайн%соглашениям) на рейсы «ДД»,
    а также с расчетным кодом 99А на рейсы «ДД» комиссионное вознаграждение Субагента составит:
    - формой оплаты НАЛ 5 (Пять) копеек с билета (Сервисный Сбор Агента составит 2 (Два) % от
      тарифа) по маршрутам (только): ВВО-ПУС; ПУС-ВВО; ВВО-ПУС/ПУС-ВВО; ПУС-ВВО/ВВО-ПУС;
      ВВО-ХАО; ХАО-ВВО; ВВО-ХАО/ХАО-ВВО; ХАО-ВВО/ВВО-ХАО; ВВО-МДН; МДН-ВВО; ВВО-МДН/МДН-ВВО;
      МДН-ВВО/ВВО-МДН; ВВО-АБН; АБН-ВВО; ВВО-АБН/АБН-ВВО; АБН-ВВО/ВВО-АБН; ВВО-КРВ; КРВ-ВВО;
      ВВО-КРВ/КРВ-ВВО; КРВ-ВВО/ВВО-КРВ; ВВО-ХБР; ХБР-ВВО; ВВО-ХБР/ХБР-ВВО; ХБР-ВВО/ВВО-ХБР;
      КЯА-ЮЖХ; ЮЖХ-КЯА; КЯА-ЮЖХ/ЮЖХ-КЯА; ЮЖХ-КЯА/КЯА-ЮЖХ; ВВО-ТОК; ВВО-ТОК/ТОК-ВВО; ХБР-ТОК;
      ХБР-ТОК/ТОК-ХБР; ВВО-НГА; ВВО-НГА/НГА-ВВО; ВВО-ТОЯ; ВВО-ТОЯ/ТОЯ-ВВО; ХБР-НГА;
      ХБР-НГА/НГА-ХБР; ВВО-ХБН; ХБН-ВВО; ВВО-ХБН/ХБН-ВВО; ХБН-ВВО/ВВО-ХБН; ХБР-ХБН;
      ХБН-ХБР; ХБР-ХБН/ХБН-ХБР; ХБН-ХБР/ХБР-ХБН; ХБР-АНЫ; АНЫ-ХБР; ХБР-АНА/АНЫ-ХБР;
      АНЫ-ХБР/ХБР-АНЫ; ВВО-АНЫ; АНЫ-ВВО; ВВО-АНЫ/АНЫ-ВВО; АНЫ-ВВО/ВВО-АНЫ; ХБР-АБН;
      АБН-ХБР; АБН-ХБР/ХБР-АБН; ХБР-АБН/АБН-ХБР; ЮЖХ-ТОК; ТОК-ЮЖХ; ТОК-ЮЖХ/ЮЖХ-ТОК;
      ЮЖХ-ТОК/ТОК-ЮЖХ,  а также по направлениям ВВО-КАВ, ВВО-ПЛА. "
carrier "ДД", "ОАО «Владивосток Авиа»"
code "277 99А"
interline false
expire "31.12.2011"
routes "ВВО-ПУС; ПУС-ВВО; ВВО-ПУС/ПУС-ВВО; ПУС-ВВО/ВВО-ПУС;
      ВВО-ХАО; ХАО-ВВО; ВВО-ХАО/ХАО-ВВО; ХАО-ВВО/ВВО-ХАО; ВВО-МДН; МДН-ВВО; ВВО-МДН/МДН-ВВО;
      МДН-ВВО/ВВО-МДН; ВВО-АБН; АБН-ВВО; ВВО-АБН/АБН-ВВО; АБН-ВВО/ВВО-АБН; ВВО-КРВ; КРВ-ВВО;
      ВВО-КРВ/КРВ-ВВО; КРВ-ВВО/ВВО-КРВ; ВВО-ХБР; ХБР-ВВО; ВВО-ХБР/ХБР-ВВО; ХБР-ВВО/ВВО-ХБР;
      КЯА-ЮЖХ; ЮЖХ-КЯА; КЯА-ЮЖХ/ЮЖХ-КЯА; ЮЖХ-КЯА/КЯА-ЮЖХ; ВВО-ТОК; ВВО-ТОК/ТОК-ВВО; ХБР-ТОК;
      ХБР-ТОК/ТОК-ХБР; ВВО-НГА; ВВО-НГА/НГА-ВВО; ВВО-ТОЯ; ВВО-ТОЯ/ТОЯ-ВВО; ХБР-НГА;
      ХБР-НГА/НГА-ХБР; ВВО-ХБН; ХБН-ВВО; ВВО-ХБН/ХБН-ВВО; ХБН-ВВО/ВВО-ХБН; ХБР-ХБН;
      ХБН-ХБР; ХБР-ХБН/ХБН-ХБР; ХБН-ХБР/ХБР-ХБН; ХБР-АНЫ; АНЫ-ХБР; ХБР-АНА/АНЫ-ХБР;
      АНЫ-ХБР/ХБР-АНЫ; ВВО-АНЫ; АНЫ-ВВО; ВВО-АНЫ/АНЫ-ВВО; АНЫ-ВВО/ВВО-АНЫ; ХБР-АБН;
      АБН-ХБР; АБН-ХБР/ХБР-АБН; ХБР-АБН/АБН-ХБР; ЮЖХ-ТОК; ТОК-ЮЖХ; ТОК-ЮЖХ/ЮЖХ-ТОК;
      ЮЖХ-ТОК/ТОК-ЮЖХ"
directions "ВВО-КАВ, ВВО-ПЛА"
consolidator "2%"
subagent "0.05"

doc "1.2.15. При продаже авиаперевозок на рейсы авиакомпании ОАО «Владивосток Авиа»
    (код «ДД») с расчетным кодом 277 (кроме перевозок по интерлайн-соглашениям)
    на рейсы «ДД», а также с расчетным кодом 99А на рейсы «ДД»:
    - С формой оплаты НАЛ на международные рейсы и рейсы внутри Российской Федерации
      комиссионное вознаграждение Субагента составит 4 (четыре) % от тарифа,  кроме направлений:
    - ВВО-БГЩ,  ВВО-ПУС, ВВО-ХАО, ВВО-МДН, ВВО-ХБР, ХБР-АНЫ, ВВО-АБН, ВВО-КРВ,
      АБН-КЛС, ВВО-АНЫ, ХБР-АБН, ВВО-КАВ, ВВО-ПЛА на рейсах «ДД» комиссионное вознаграждение
      Субагента составит 50 (пятьдесят) копеек с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа;
    С формой оплаты НАЛ по следующим маршрутам: ВВО-ТОК, ВВО-ТОК-ВВО, ХБР-ТОК, ХБР-ТОК-ХБР:
    - комиссионное вознаграждение Субагента составит 50 (пятьдесят) копеек с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа;"
code "277 99А"
interline false
directions "ВВО-БГЩ,  ВВО-ПУС, ВВО-ХАО, ВВО-МДН, ВВО-ХБР, ХБР-АНЫ, ВВО-АБН, ВВО-КРВ,
 АБН-КЛС, ВВО-АНЫ, ХБР-АБН, ВВО-КАВ, ВВО-ПЛА"
routes "ВВО-ТОК, ВВО-ТОК-ВВО, ХБР-ТОК, ХБР-ТОК-ХБР"
consolidator "2%"
subagent "0.5"

doc "1.2.17. При продаже авиаперевозок с формой оплаты НАЛ и РТА на рейсы авиакомпании
    ОАО АВИАЦИОННАЯ ТРАНСПОРТНАЯ КОМПАНИЯ «ЯМАЛ» (код ЛА) с расчетным кодом 664
    (кроме перевозок по интерлайн-соглашениям) на рейсы «ЛА», а также с расчетным кодом 99А
    на рейсы «ЛА» комиссионное вознаграждение Субагента составит 1,5 (один с половиной) % от тарифа."
carrier "ЛА", "ОАО АВИАЦИОННАЯ ТРАНСПОРТНАЯ КОМПАНИЯ «ЯМАЛ»"
code "664 99А"
interline false
subagent "1.5%"

doc "1.2.18. При продаже авиаперевозок с формой оплаты НАЛ и РТА по маршрутам:
    НУР-БЕД, БЕД-НУР, НУР-БЕД-НУР, БЕД-НУР-БЕД, МОВ-БЛР, БЛР-МОВ, МОВ-БЛР-МОВ,
    БЛР-МОВ-БЛР, СОЙ-НДМ, НДМ-СОЙ, НДМ-СОЙ-НДМ, СОЙ-НДМ-СОЙ на рейсы авиакомпании
    ООО «АВИАПРЕДПРИЯТИЕ «ГАЗПРОМАВИА» (код ОП) с расчетным кодом 36А (кроме перевозок
    по интерлайн-соглашениям) на рейсы «ОП», а также с расчетным кодом 99А на
    рейсы «ОП» комиссионное вознаграждение Субагента составит 1 (один) % от тарифа."
carrier "ОП", "ООО «АВИАПРЕДПРИЯТИЕ «ГАЗПРОМАВИА»"
code "36А 99A"
interline false
subagent "1%"

doc "1.2.19. При продаже авиаперевозок с формой оплаты НАЛ и РТА на рейсы авиакомпании
    ОАО «САРАТОВСКИЕ АВИАЛИНИИ» (код «6В») с расчетным кодом 026 (кроме перевозок
    по интерлайн-соглашениям) на рейсы «6В», а также с расчетным кодом 99А на рейсы «6В»
    комиссионное вознаграждение Субагента составит 3 (три) % от тарифа."
carrier "6В", "ОАО «САРАТОВСКИЕ АВИАЛИНИИ»"
code "026 99А"
interline false
subagent "3%"

doc "1.2.20. При продаже авиаперевозок с формой оплаты НАЛ и РТА на рейсы
    ОАО «АВИАЛИНИИ ДАГЕСТАНА» (код ЮХ) с расчетным кодом 394 (кроме перевозок по
    интерлайн-соглашениям) на рейсы «ЮХ», а также с расчетным кодом 99А на рейсы «ЮХ»
    комиссионное вознаграждение Субагента составит 1 (один) % от тарифа."
carrier "ЮХ", "ОАО «АВИАЛИНИИ ДАГЕСТАНА»"
code "394 99А"
interline false
subagent "1%"

doc "1.2.21. При продаже авиаперевозок с формой оплаты НАЛ и РТА на рейсы
    ОАО «АВИАЛИНИИ МОРДОВИИ» (код ПМ) с расчетным кодом 95А (кроме перевозок по
    интерлайн-соглашениям) на рейсы «ПМ», а также с расчетным кодом 99А на рейсы «ПМ»:
    - комиссионное вознаграждение Субагента составит 5 (пять) рублей c билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "ПМ", "ОАО «АВИАЛИНИИ МОРДОВИИ»"
code "95А 99А"
interline false
consolidator "2%"
subagent "5"

doc "1.2.22. При продаже авиаперевозок с формой оплаты НАЛ и РТА на рейсы авиакомпании 
    ЗАО «АЗЕРБАЙДЖАН ХАВА ЙОЛЛАРЫ» (код J2) с расчетным кодом 771 (кроме перевозок
    по интерлайн-соглашениям) на рейсы «J2», а также с расчетным кодом 99А на рейсы «J2»:
    По маршрутам: ГНЖ-МОВ; МОВ-ГНЖ; МОВ-ГНЖ-МОВ; ГНЖ-МОВ-ГНЖ; БАК-ЕКБ; ЕКБ-БАК;
    ЕКБ-БАК-ЕКБ; БАК-ЕКБ-БАК; ГНЖ-ИСТ; ИСТ-ГНЖ; ГНЖ-ИСТ-ГНЖ; ИСТ-ГНЖ-ИСТ; БАК-KSY (КАРС);
    KSY-БАК; KSY-БАК-KSY; БАК-KSY-БАК - комиссионное вознаграждение Субагента
    рассчитывается согласно пункта 1.2.2. настоящего Приложения.
    По всем остальным маршрутам комиссионное вознаграждение Субагента составит:
    - 50 (пятьдесят) копеек c билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "J2", "ЗАО «АЗЕРБАЙДЖАН ХАВА ЙОЛЛАРЫ»"
code "771 99А"
interline false
routes "ГНЖ-МОВ; МОВ-ГНЖ; МОВ-ГНЖ-МОВ; ГНЖ-МОВ-ГНЖ; БАК-ЕКБ; ЕКБ-БАК; ЕКБ-БАК-ЕКБ;
 БАК-ЕКБ-БАК; ГНЖ-ИСТ; ИСТ-ГНЖ; ГНЖ-ИСТ-ГНЖ; ИСТ-ГНЖ-ИСТ; БАК-KSY (КАРС); KSY-БАК;
 KSY-БАК-KSY; БАК-KSY-БАК"
subagent "4%"

consolidator "2%"
subagent "0.5"

doc "1.2.23. При продаже перевозок с формой оплаты НАЛ и РТА на рейсы
    ОАО «КИРОВСКОЕ АВИАПРЕДПРИЯТИЕ» (код ЭВ) с расчетным кодом 51В (кроме рейсов
    по интерлайн-соглашениям) на рейсы «ЭВ», а также с расчетным кодом 99А на рейсы «ЭВ»:
    - комиссионное вознаграждение Субагента составит 1 (один) рубль с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "ЭВ", "ОАО «КИРОВСКОЕ АВИАПРЕДПРИЯТИЕ»"
code "51В 99А"
interline false
consolidator "2%"
subagent "1"

doc "1.2.24. При продаже перевозок с формой оплаты НАЛ и РТА на рейсы
    ООО «ГРОЗНЫЙ АВИА» (код ГГ) с расчетным кодом 55В (включая перевозки на всем
    интерлайн-соглашениям) на рейсы «ГГ», а также с расчетным кодом 99А на рейсы
    «ГГ» комиссионное вознаграждение Субагента составит 1 (один) %  от тарифа."
carrier "ГГ", "ООО «ГРОЗНЫЙ АВИА»"
code "55В 99А"
interline true
subagent "1%"

doc "1.2.25. При продаже перевозок на рейсы авиакомпании EMIRATES (код EK) 
    с расчетным кодом 176, а также с расчетным кодом 99А на рейсы «EK» комиссионное
    ознаграждение Субагента составит:
    - На перевозки c кодами подклассов: P, F, A, J, C, I, O (латиница),
     (кроме перевозок по всем интерлайн-соглашениям):
    3 (три) % от тарифа с формой оплаты НАЛ;
    - На все остальные перевозки, включая перевозки по всем интерлайн-соглашениям:
    5 (пять) коп. с билета формой оплаты НАЛ. Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "EK", "EMIRATES"
code "176 99А"
interline false
subclasses "P, F, A, J, C, I, O"
subagent "3%"

consolidator "2%"
subagent "0.05"

doc "1.2.26. При продаже перевозок на рейсы ОАО «Авиакомпания «ТАЙМЫР» (код ТИ) 
    с расчетным кодом 476 (кроме перевозок по интерлайн-соглашениям) на рейсы «ТИ»,
    а также с расчетным кодом 99А на рейсы «ТИ» комиссионное вознаграждение Субагента составит:
    с формой оплаты НАЛ: 1 (один) % от тарифа;"
carrier "ТИ", "ОАО «Авиакомпания «ТАЙМЫР»"
code "476 99А"
interline false
subagent "1%"

doc "1.2.28. Начиная с 11 сентября 2010г. при продаже авиаперевозок c формой оплаты
    НАЛ на рейсы авиакомпании Air Berlin PLC & Co Luftverkehrs (код AB) с расчетным кодом 745
    (кроме перевозок по всем интерлайн-соглашениям)
    - комиссионное вознаграждение Субагента составит 5 (пять) коп. с билета.
    - Сервисный Сбор Агента составит 2 (два) % от тарифа."
carrier "AB", "Air Berlin PLC & Co Luftverkehrs"
code "745"
interline false
consolidator "2%"
subagent "0.05"

doc "1.2.29. Начиная с 01 октября 2010г. при продаже авиаперевозок c формой
    оплаты НАЛ на рейсы авиакомпании ЗАО «Ист Эйр» (код ДЭ) с расчетным кодом 66В
    (кроме перевозок по всем интерлайн-соглашениям) комиссионное вознаграждение
    Субагента составит 6 (шесть) % от тарифа. "
carrier "ДЭ", "ЗАО «Ист Эйр»"
code "66В"
interline false
subagent "6%"

doc "2. С 01 апреля 2011г. при продаже авиаперевозок с формой оплаты НАЛ и РТА
    на ЕТ и БСО НСАВ ТКП на рейсы авиакомпании ОАО «АВИАКОМПАНИЯ «СИБИРЬ» (код С7)
    с расчетным кодом 421 (включая перевозки по всем интерлайн-соглашениям) на рейсы
    «С7», а также с расчетным кодом 99А на рейсы «С7» комиссионное вознаграждение
    Субагента составит 1 (один) % (включая НДС) от тарифа."
carrier "S7", "ОАО «Авиакомпания «СИБИРЬ»"
code "421 99A"
subagent "1%"

doc "1. На период с 01.04.2011г. по 31.05.2011г. при продаже с формой оплаты НАЛ
    и РТА на ЕТ и БСО НСАВ ТКП на рейсы авиакомпании ЗАО «Нордавиа - РА» (код «5H»)
    с расчетным кодом 316 (кроме перевозок по интерлайн-соглашениям) на рейсы «5H»
    комиссионное вознаграждение Субагента составит:
    - 5 коп с билета, (Сервисный Сбор Агента составит 2 (Два) % от тарифа), если
     авиаперевозка полностью соответствует условиям: Код тарифа: FSSOW; FSS1M: FPROMCH,
     а также маршруты (только): НРС-ОВБ; ОВБ-НРС; НРС-ОВБ/ОВБ-НРС; ОВБ-НРС/НРС-ОВБ;
     ОВБ-КРР; КРР-ОВБ; ОВБ-КРР/КРР-ОВБ; КРР-ОВБ/ОВБ-КРР; НРС-КРР; КРР-НРС; НРС-КРР/КРР-НРС;
     КРР-НРС/НРС-КРР; ТСК-СОЧ; СОЧ-ТСК; ТСК-СОЧ/СОЧ-ТСК;СОЧ-ТСК/ТСК-СОЧ; НРС-СОЧ; СОЧ-НРС;
     НРС-СОЧ/СОЧ-НРС; СОЧ-НРС/НРС-СОЧ; НРС-ЕКБ; ЕКБ-НРС;НРС-ЕКБ/ЕКБ-НРС; ЕКБ-НРС/НРС-ЕКБ;
     ЕКБ-РОВ; РОВ-ЕКБ; ЕКБ-РОВ/РОВ-ЕКБ; РОВ-ЕКБ/ЕКБ-РОВ; НРС-РОВ; РОВ-НРС; НРС-РОВ/РОВ-НРС;
     РОВ-НРС/НРС-РОВ; НРС-УФА; УФА-НРС; НРС-УФА/УФА-НРС; УФА-НРС/НРС-УФА; УФА-АНА; АНА-УФА;
     УФА-АНА/АНА-УФА; АНА-УФА/УФА-АНА; НРС-АНА; АНА-НРС; НРС-АНА/АНА-НРС; АНА-НРС/НРС-АНА;
     МОВ-УФА; УФА-МОВ; МОВ-УФА/УФА-МОВ; УФА-МОВ/МОВ-УФА; МОВ-НРС; НРС-МОВ; МОВ-НРС/НРС-МОВ;
     НРС-МОВ/МОВ-НРС; АРХ-ХЕЛ; ХЕЛ-АРХ; АРХ-ХЕЛ/ХЕЛ-АРХ; ХЕЛ-АРХ/АРХ-ХЕЛ; МУН-ХЕЛ; ХЕЛ-МУН;
     МУН-ХЕЛ/ХЕЛ-МУН; ХЕЛ-МУН/МУН-ХЕЛ; НРС-ЧЛБ; ЧЛБ-НРС; ЧЛБ-СОЧ; СОЧ-ЧЛБ.
   - 5 коп с билета, (Сервисный Сбор Агента составит 2 (Два) % от тарифа), если авиаперевозка
     содержит участок с Кодом тарифа: FSSOW; FSS1M: FPROMCH."
carrier "5H", "ЗАО «Нордавиа - РА»"
code "316"
expire "31.05.2011"
fares "FSSOW; FSS1M: FPROMCH"
interline false
consolidator "2%"
subagent "0.05"


end
