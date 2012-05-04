require 'test_helper'
require 'rails/performance_test_help'

class HomepageTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def test_homepage
   stub_request(:get, "http://api.ipinfodb.com/v3/ip-city?format=json&ip=127.0.0.1&key=3d6f13ecf08dbb20b0195a48d04d13996dcacfafceec4403dfab373dd89024f3&timezone=false").
     with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
     to_return(:status => 200, :body => "", :headers => {})

   get '/'
  end
end
