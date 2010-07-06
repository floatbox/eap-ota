class Airline < ActiveRecord::Base
  include ExtResource
  
  has_many :interline_agreements,
    :foreign_key => 'company_id',  :class_name => 'InterlineAgreement'
  
  has_many :interline_partners,
    :through => :interline_agreements, :source => :partner

  
  belongs_to :country

  def name
    [ru_longname, ru_shortname,  en_longname, en_shortname, iata].find(&:present?)
  end

  def icon_url
    "url(/system/airlines/icons/#{iata}.gif)"
  end
  
  def short_name
    [ru_shortname, en_shortname].find(&:present?)
  end

end
