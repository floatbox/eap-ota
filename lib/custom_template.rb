class CustomTemplate < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include ApplicationHelper

  #def default_url_options
  #  {host: 'yourhost.org'}
  #end
  def initialize *args
    args[0] ||= Rails.root.join('app', 'views')
    super(*args)
  end
end
