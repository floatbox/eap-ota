# encoding: utf-8
require 'pp'
module LogJSON
  def self.debug(struct)
    io = StringIO.new
    destringified = JSON.parse(struct.to_json)
    pp destringified, io
    Rails.logger.debug io.string
    struct
  end
end
