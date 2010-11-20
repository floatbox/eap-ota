class Airline < ActiveRecord::Base
  include ExtResource
  extend IataStash
  
  has_many :interline_agreements,
    :foreign_key => 'company_id',  :class_name => 'InterlineAgreement'
  
  has_many :interline_partners,
    :through => :interline_agreements, :source => :partner

  has_many :amadeus_commissions
  belongs_to :alliance, :foreign_key => 'airline_alliance_id', :class_name => 'AirlineAlliance'
  
  belongs_to :country

  def name
    ru_longname.presence ||
      ru_shortname.presence ||
      en_longname.presence ||
      en_shortname.presence ||
      iata
  end
  
  
  def avaliable_bonus_programms
    #бонусные программы авиакомпаний, входящие в тот же альянс, что и данная
    #пока без бонусной программы альянса
    if alliance
      return alliance.airlines.find(:all, :conditions => 'bonus_program_name IS NOT NULL AND bonus_program_name != ""', :order => 'bonus_program_name')
    end
    return []
  end

  def icon_url
    url = "/img/system/airlines/#{iata}.gif"
    unless File.exist?("#{Rails.root}/public#{url}")
      url = "/img/system/airlines/default.gif"
    end
    url
  end
  
  def short_name
    ru_shortname.presence || en_shortname
  end

  # TODO перенести в amadeus.rb или куда-то в более нейтральное место
  # TODO выкачать/закэшировать пакетно
  def fetch_interline_iatas
    Amadeus::Session.with_session do |s|
      res = Amadeus::Service.cmd("TGAD-#{iata}", s)
      res.sub!(/^(.*)\n/, '');
      if $1 == '/'
        # нет такого перевозчика или интерлайна
        # FIXME сделать класс для эксепшнов
        raise res.strip
      end
      # добываем следующие страницы, если есть
      while res.sub! /\)\s*\Z/, ''
        res << Amadeus::Service.cmd('MD', s)[2..-1]
      end
      res
    end \
      .split(/\s*-\s+/) \
      .collect {|s| s.split(' ', 2) } \
      .select {|airline, agreement| agreement['E'] && !agreement['*']} \
      .collect {|airline,_| airline}
  end

end
