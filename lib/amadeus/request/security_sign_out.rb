# encoding: utf-8
module Amadeus
  module Request
    class SecuritySignOut < Amadeus::Request::Base

      # пустое тело, шаблон не нужен
      def soap_body; '' end

    end
  end
end
