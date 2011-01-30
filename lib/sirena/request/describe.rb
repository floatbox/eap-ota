# encoding: utf-8
module Sirena
  module Request
    class Describe < Sirena::Request::Base
      attr_accessor :data, :code, :show_all, :company, :show_real_codes
      # это должно быть здесь, я уже всеоо придумал
      def initialize(params)
        params.each{|k, v| self.send(k.to_s+"=", v)}
      end

    end
  end
end