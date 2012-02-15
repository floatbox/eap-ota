# encoding: utf-8
class Carrier < ActiveRecord::Base
  extend IataStash

  has_paper_trail

  has_many :amadeus_commissions
  belongs_to :alliance, :foreign_key => 'airline_alliance_id', :class_name => 'AirlineAlliance'

  belongs_to :country
  belongs_to :consolidator
  belongs_to :gds, :foreign_key => 'gds_id', :class_name =>'GlobalDistributionSystem'

  def name
    ru_longname.presence ||
      ru_shortname.presence ||
      en_longname.presence ||
      en_shortname.presence ||
      iata
  end

  def name_en
      en_longname.presence ||
      en_shortname.presence ||
      iata
  end

  def available_bonus_programms
    #бонусные программы авиакомпаний, входящие в тот же альянс, что и данная
    #пока без бонусной программы альянса
    @available_bonus_programs ||= if alliance
      alliance.carriers.where('bonus_program_name IS NOT NULL AND bonus_program_name != ""').order('bonus_program_name').all
    elsif bonus_program_name.present?
      [self]
    else
      []
    end
  end

  def self.non_commissioned_iatas
    (where('consolidator_id is NULL AND iata != ""').find_all{|a| Commission.commissions[a.iata]}).to_a[0..98].collect(&:iata)
  end

  def icon_url
    url = "/img/carriers/#{iata}.gif"
    unless File.exist?("#{Rails.root}/public#{url}")
      url = "/img/carriers/default.gif"
    end
    url
  end

  # попытка сделать картинку для админки. можно как-то лучше сделать
  def icon_img
    "<img src='#{icon_url}'>".html_safe
  end

  def self.model_fields
    super.merge(:icon_img => :file)
  end

  def short_name
    ru_shortname.presence || en_shortname
  end

  def fetch_interlines(session=Amadeus.booking)
    if iata.present?
      session.interline_iatas(iata)
    else
      []
    end
  rescue Curl::Err::HostResolutionError
    retries ||= 3
    retries -= 1
    retry unless retries.zero?
    []
  rescue Amadeus::Macros::CommandCrypticError
    []
  end

  def update_interlines!(session=Amadeus.booking)
    self.interlines = fetch_interlines(session).join(' ')
    has_changed = changed?
    save
    has_changed
  end

  def interline_with?(carrier)
    carrier = carrier.iata if carrier.is_a? Carrier
    interlines.split.include?(carrier)
  end

  def interline_partners
    interlines.split.map {|iata| Carrier[iata]}
  end

  # для кронтаска
  def self.update_interlines!
    Amadeus.booking do |session|
      all.map do |carrier|
        carrier.update_interlines!(session)
      end.count(&:present?)
    end
  end
end

