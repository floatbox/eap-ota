# encoding: utf-8
class Carrier < ActiveRecord::Base
  extend CodeStash

  def self.fetch_by_code(code)
    find_by_iata(code)  # || find_by_iata_ru(code)
  end

  has_paper_trail

  belongs_to :alliance, :foreign_key => 'airline_alliance_id', :class_name => 'AirlineAlliance'

  belongs_to :country
  belongs_to :consolidator
  belongs_to :gds, :foreign_key => 'gds_id', :class_name =>'GlobalDistributionSystem'
  serialize :interlines, JoinedArray.new
  serialize :not_interlines, JoinedArray.new

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

  def self.commissioned_iatas
    Commission.carriers
  end

  def icon_url
    url = "/images/carriers/#{iata}.png"
    unless File.exist?("#{Rails.root}/public#{url}")
      url = "/images/carriers/default.gif"
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

  def all_iatas
    [iata] + not_interlines
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
    self.interlines = fetch_interlines(session)
    return changed?
  ensure
    save
  end

  def confirmed_interline_with?(carrier)
    carrier = carrier.iata unless carrier.is_a? String
    interlines.include?(carrier)
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

