module TimeChecker
  def self.ok_to_sell dept_date, last_tkt_date = nil
    if Time.now.hour < 17
      dept_date > Date.today
    elsif Time.now.hour >= 17 && Time.now < (Date.today + 20.hours + 30.minutes)
      dept_date > Date.today + 1.day
    else
      last_tkt_date ||= Date.today + 1.day
      dept_date > Date.today + 1.day && last_tkt_date > Date.today
    end
  end

end
