module Discount
  class SectionNotFound < LoadError; end
end

require 'discount/book'
require 'discount/rule'
require 'discount/section'
require 'discount/finder'
Dir[Rails.root.join('config', 'discounts', '*.rb')].each do |f|
  require f
end
