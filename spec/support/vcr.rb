require 'vcr'

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end

VCR.config do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.stub_with :webmock # or :fakeweb
end
