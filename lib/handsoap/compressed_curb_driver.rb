module Handsoap

  class CompressedCurbDriver < Handsoap::Http::Drivers::CurbDriver
    private
    def get_curl(*)
      curl = super
      # enables both deflate and gzip responses
      curl.encoding = ''
      curl
    end

    include NewRelic::Agent::MethodTracer
    add_method_tracer :send_http_request, 'Custom/Handsoap/http'

  end

end
Handsoap::Http.drivers[:compressed_curb] = Handsoap::CompressedCurbDriver
