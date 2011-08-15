# encoding: utf-8
module Admin::OrderCommentsHelper
  include ActionView::Helpers::TextHelper
  include Admin::Resources::DataTypes::StringHelper
  alias_method :integer_filter, :string_filter
# переопредилил метод truncate для нормального показа комментариев к заказу в админке 
  def truncate(text, options = {})
#    super(text, :length => 100)
    simple_format(text)
  end

end
