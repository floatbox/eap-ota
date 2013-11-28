class Alfastrah
  class Passenger
    include Virtus.value_object

    values do
      attribute :first_name, String
      attribute :last_name, String
      attribute :birth_date, Date
      attribute :ticket_number, String
      attribute :document_number, String
      attribute :document_type, String
      attribute :email, String
    end
  end
end
