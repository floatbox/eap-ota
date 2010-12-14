module Handsoap

  class CompressedCurbDriver < Handsoap::Http::Drivers::CurbDriver
    private
    def get_curl(*)
      curl = super
      # enables both deflate and gzip responses
      curl.encoding = ''
      curl
    end
  end

end
Handsoap::Http.drivers[:compressed_curb] = Handsoap::CompressedCurbDriver
