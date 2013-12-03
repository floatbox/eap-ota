module Typus
  module Authentication
    # оригинальный модуль для Devise неправильно вычислял пути для авторизации Deck::User
    module EviterraDevise

      protected

      include Base

      def admin_user
        current_deck_user
      end

      def authenticate
        authenticate_deck_user!
      end

    end
  end
end
