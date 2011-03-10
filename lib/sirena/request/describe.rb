# encoding: utf-8
module Sirena
  module Request
    class Describe < Sirena::Request::Base
      attr_accessor :data, :code, :show_all, :company, :show_real_codes
    end
  end
end
