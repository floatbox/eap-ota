class InterlineAgreement < ActiveRecord::Base
  belongs_to :airline,
    :class_name => 'Airline', :foreign_key => 'company_id'
  belongs_to :partner,
    :class_name => 'Airline', :foreign_key => 'partner_id'
    
  after_save :save_reverted_if_needed
  before_destroy :destroy_reverted_if_needed
  
  def save_reverted_if_needed
    InterlineAgreement.find_or_create_by_partner_id_and_company_id(company_id, partner_id)
  end
  
  def destroy_reverted_if_needed
    InterlineAgreement.find(:first, :conditions => {:partner_id => company_id, :company_id => partner_id}).destroy
  end
end

