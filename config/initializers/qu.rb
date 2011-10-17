Qu.configure do |c|
  c.logger      = Logger.new('log/qu.log')
  # ради отметок о времени.
  c.logger.formatter = Logger::Formatter.new
end
