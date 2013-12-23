module Discount
  class SectionNotFound < LoadError; end

  class << self
    def default_book
      @book || reload!
    end

    def reload!
      @book = begin
        Rails.logger.info 'Reloading discounts'
        book = Discount::Book.new
        book.instance_eval File.read(discount_file)
        book
      end
    end

    private

    def discount_file
      Rails.root.join 'config', 'discounts', 'all.rb'
    end
  end
end

require 'discount/book'
require 'discount/rule'
require 'discount/section'
require 'discount/finder'
