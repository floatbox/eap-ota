# encoding: utf-8
require 'base64'

class Sirena::Response::GetItinReceipts < Sirena::Response::Base

  attr_accessor :pdf

  def parse
    b64pdf = xpath('//receipts').text
    @pdf = Base64::decode64(b64pdf)
  end

end
