class Order < ActiveRecord::Base
  validates_presence_of :email#, :phone
  
  def recommendation= recommendation
    self.price_total = recommendation.price_total
    if c = recommendation.commission
      self.commission_carrier = c.carrier
      self.commission_agent = c.agent
      self.commission_subagent = c.subagent
      self.price_share = recommendation.price_share
      self.price_markup = recommendation.price_markup
    end
  end
  
  def create_booking(recommendation, card, order_id, people)
    result = Payture.new.block(recommendation.price_with_payment_commission, card, :order_id => order_id)
    if result["Success"] != "True"
      card.errors.add :number, ("не удалось провести платеж (#{result["ErrCode"]})" )
      return nil
    else
      amadeus = Amadeus.new(:book => true)
      air_sfr_xml = amadeus.soap_action('Air_SellFromRecommendation',
        :segments => recommendation.variants[0].segments, :people_count => people.count
      )
      
      doc = amadeus.pnr_add_multi_elements(PNRForm.new(
        :flights => [],
        :people => people,
        :phone => '1236767',
        :email => email,
        :validating_carrier => recommendation.validating_carrier.iata
      ))
      self.pnr_number = doc.xpath('//r:controlNumber').to_s
      
      if pnr_number
        amadeus.soap_action('Fare_PricePNRWithBookingClass')
        amadeus.soap_action('Ticket_CreateTSTFromPricing')
        amadeus.pnr_add_multi_elements(PNRForm.new(:end_transact => true))
        amadeus.soap_action('Queue_PlacePNR', :number => pnr_number)
        save
        PnrMailer.deliver_pnr_notification(email, pnr_number) if email
        amadeus.session.destroy
        return pnr_number
      else
        errors.add :pnr_number, 'Ошибка при создании PNR' 
        return nil
      end
    end
  end
  
  
  def validate
    errors.add :email,           "Некорректный email"    if email && !(email =~ /^[a-zA-Z@\.]*$/)
    #errors.add :phone,       "Некорректный телефон"  if phone && !(phone =~ /^[0-9]*$/)
  end
end

=begin
имя пассажира
телефон
email пассажира
номер pnr
=end
