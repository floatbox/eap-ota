class Sirena::Commission
  include KeyValueInit
  cattr_accessor :commissions, :opts
  self.commissions = {}
  self.opts = {}

  attr_accessor :carrier, :carrier_name, :doc, :code, :consolidator, :subagent,
    :interline, :subclasses, :routes, :expire, :fares

  class << self
    [:doc, :code, :consolidator, :interline, :subclasses,
     :routes, :expire, :fares].each{|method_name|
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
      self.opts = {:carrier=>opts[:carrier], :carrier_name=>opts[:carrier_name]}
    end
  end

doc "1.2. На БСО ЗАО «Транспортная Клиринговая Палата»:
    1.2.1. При продаже и оформлении авиаперевозок на БСО и электронных билетах
    СПД НСАВ – ТКП Агент устанавливает целевой сервисный сбор за каждый проданный
    Субагентом авиабилет в размере 50 (пятьдесят) рублей. При добровольном и
    вынужденном возврате авиабилетов этот сбор Субагенту возвращается.
    1.2.2. При продаже и оформлении авиаперевозок на БСО и электронных билетах
    СПД НСАВ – ТКП комиссионное вознаграждение Субагента составит 4 (четыре) %
    от тарифа на все авиакомпании входящие в ТКП, кроме:  "
consolidator "50"
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
    - с формой оплаты НАЛ и кодами подклассов: Y, H, M, Q, B, K (латиница); Э, Ц, М, Я, Ж, К (кириллица) 5 (пять) % от тарифа;
    - с формой оплаты НАЛ и кодами подклассов: L, V, X, T, N, I, W (латиница); Л, В, Х, Т, Н, Ы, Ю (кириллица) 1 (один) % от тарифа;
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
subclasses "Y, H, M, Q, B, K, Э, Ц, М, Я, Ж, К"
subagent "5%"

code "670 99А"
interline false
subclasses "L, V, X, T, N, I, W, Л, В, Х, Т, Н, Ы, Ю"
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
carrier "МА", "MALEV HUNGARIAN AIRLINES LTD"
code "182"
interline false
consolidator "2%"
subagent "0.5"

doc "1.2.15. При продаже авиаперевозок на рейсы авиакомпании ОАО «Владивосток Авиа»
    (код «ДД») с расчетным кодом 277 (кроме перевозок по интерлайн-соглашениям)
    на рейсы «ДД», а также с расчетным кодом 99А на рейсы «ДД»:
    - С формой оплаты НАЛ на международные рейсы и рейсы внутри Российской Федерации
      комиссионное вознаграждение Субагента составит 4 (четыре) % от тарифа,  кроме направлений:
    - ВВО-БГЩ,  ВВО-ПУС, ВВО-ХАО, ВВО-МДН, ВВО-ХБР, ХБР-АНЫ, ВВО-АБН, ВВО-КРВ,
      АБН-КЛС, ВВО-АНЫ, ХБР-АБН, ВВО-КАВ, ВВО-ПЛА на рейсах «ДД» комиссионное вознаграждение Субагента составит 50 (пятьдесят) копеек с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа;
    С формой оплаты НАЛ по следующим маршрутам: ВВО-ТОК, ВВО-ТОК-ВВО, ХБР-ТОК, ХБР-ТОК-ХБР:
    - комиссионное вознаграждение Субагента составит 50 (пятьдесят) копеек с билета;
    - Сервисный Сбор Агента составит 2 (два) % от тарифа;"
carrier "ДД", "ОАО «Владивосток Авиа»"
code "277 99А"
interline false
routes "ВВО-БГЩ,  ВВО-ПУС, ВВО-ХАО, ВВО-МДН, ВВО-ХБР, ХБР-АНЫ, ВВО-АБН, ВВО-КРВ,
 АБН-КЛС, ВВО-АНЫ, ХБР-АБН, ВВО-КАВ, ВВО-ПЛА, ВВО-ТОК, ВВО-ТОК-ВВО, ХБР-ТОК, ХБР-ТОК-ХБР"
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

doc "5.3. на период по 30.09.2011 года при продаже собственных авиаперевозок 
    ОАО «Авиакомпания «СИБИРЬ» (S7) по маршрутам ASB-MOW и MOW-ASB вознаграждение
    СУБАГЕНТА составит 3% (включая НДС) от тарифа."
carrier "S7", "ОАО «Авиакомпания «СИБИРЬ»"
routes "ASB-MOW, MOW-ASB"
expire "30.09.2011"
subagent "3%"

end
