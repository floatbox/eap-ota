module Discount
  class SectionNotFound < LoadError; end

  class << self

    delegate :register,
        to: :default_book

    def default_book
      @book ||= Discount::Book.new
    end

  end

end

require 'discount/book'
require 'discount/rule'
require 'discount/section'
require 'discount/finder'
Dir[Rails.root.join('config', 'discounts', '*.rb')].each do |f|
  require f
end
