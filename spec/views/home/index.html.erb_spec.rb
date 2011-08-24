require 'spec_helper'

describe "home/index.html.erb" do
  before(:each) do
    view.stub(:nearest_city).and_return(Location.default)
    view.stub(:admin_user).and_return(false)
  end

  it "shows 'Вы находитесь в корпоративном режиме' if corporate mode is on" do
    view.stub(:'corporate_mode?').and_return(true)
    render
    rendered.should contain("Вы находитесь в корпоративном режиме")
  end


  it "doesn't show 'Вы находитесь в корпоративном режиме' if corporate mode is off" do
    view.stub(:'corporate_mode?').and_return(nil)
    render
    rendered.should_not contain("Вы находитесь в корпоративном режиме")
  end

  it "should show link to exit corporate mode" do
    view.stub(:'corporate_mode?').and_return(true)
    render
    rendered.should have_selector("a",
      :href => stop_corporate_url
    ) do |a|
      a.should contain('Выйти')
    end

  end

end
