class Airline < ActiveRecord::Base
  include ExtResource
  extend IataStash
  
  has_many :interline_agreements,
    :foreign_key => 'company_id',  :class_name => 'InterlineAgreement'
  
  has_many :interline_partners,
    :through => :interline_agreements, :source => :partner

  has_many :amadeus_commissions
  
  belongs_to :country

  def name
    ru_longname.presence ||
      ru_shortname.presence ||
      en_longname.presence ||
      en_shortname.presence ||
      iata
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

end
