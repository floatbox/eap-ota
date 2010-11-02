module Amadeus

  class Error < StandardError
  end

  def self.fake=(value); $amadeus_fake=value; end
  def self.fake; $amadeus_fake; end

end
