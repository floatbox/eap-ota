# encoding: utf-8
module Sirena
  module Request
    class Fareremark < Sirena::Request::Base
      attr_accessor :carrier, :upt_code, :upt
    end
  end
end

