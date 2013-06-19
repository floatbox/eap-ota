module Our
  module Curl
    class LogSubscriber < ActiveSupport::LogSubscriber

      def request(event)
        curl = event.payload[:curl]

        host = URI.parse(curl.url).host
        msg = "Curl: #{host} "
        msg << " err:#{curl.response_code}" unless curl.response_code == 0 or curl.response_code == 200
        msg << " %dms (l:%dms c:%dms p:%dms s:%dms) dl:%.3fKB (%.3fKB/s)" % [
          curl.total_time * 1000,
          curl.name_lookup_time * 1000,
          curl.connect_time * 1000,
          curl.pre_transfer_time * 1000,
          curl.start_transfer_time * 1000,
          curl.downloaded_bytes / 1000,
          curl.download_speed / 1000
        ]
        msg << " ul:%.3fKB (%.3fKB/s)" % [
          curl.uploaded_bytes / 1000,
          curl.upload_speed / 1000
        ] unless curl.uploaded_bytes == 0

        info(msg)
      end

      attach_to :curl

    end
  end
end
