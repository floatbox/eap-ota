# spec/integration/google_bot_aware_spec.rb
#
# This integration test is intended to check if your application is correctly managing
# GoogleBot's requests which may have an Accept header looking like this: '*/*;q=0.6'.
#
# This should be the case if GoogleBotAware Rack middleware is correctly loaded, and is
# correctly behaving.
#
require 'spec_helper'

describe "GoogleBot aware" do

  ['/'].each do |path|

    it "should be successful for a Google-Bot-style request on '#{path}'"  do
      get path, nil, {"HTTP_ACCEPT" => "*/*;q=0.9"}
      response.should be_successful
    end

  end
end
