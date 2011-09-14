class Sirena::Request::GetItinReceipts < Sirena::Request::Order

  def initialize(number, lead_pass)
    @number = number
    @lead_pass = lead_pass
  end
end
