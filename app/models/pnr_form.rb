class PNRForm < ActiveRecord::BaseWithoutTable
  attr_accessor :flights
  attr_accessor :people, :adults, :children, :infants, :people_count
  attr_accessor :commission
  column :phone, :string
  column :email, :string
  column :debug, :string
  column :number, :string
  column :end_transact, :boolean, false
  column :validating_carrier, :string
  
  validates_presence_of :first_name, :surname
  
  def to_key
    []
  end
  
  def flight_codes= codes
    self.flights = codes.map do |flight_code|
      Flight.from_flight_code flight_code
    end
  end
  
  def flight_codes
    flights.every.flight_code
  end
  
  def valid?
    first_name.present? && surname.present?
  end
  
  def get_pnr
    # FIXME возвращает "грязную" сессию!1
    response = Amadeus::Service.pnr_add_multi_elements(self)
    repsonse.pnr_number.presence || response.error_text
  end
  
  def create_order pnr_number
    Order.create(:first_name => self.first_name, :surname => self.surname, :email => self.email, :pnr_number => pnr_number, :phone => self.phone)
  end

end
