module Our
  module Curl
    class MonitoringLogSubscriber < ActiveSupport::LogSubscriber

      def request(event)
        curl = event.payload[:curl]

        # TODO отразить в счетчиках, к какому хосту был запрос
        host = URI.parse(curl.url).host,
        base = 'curl.request.'

        Monitoring.meter service: base + "response_code.#{curl.response_code}"
        Monitoring.meter service: base + "http_connect_code.#{curl.http_connect_code}"
        Monitoring.histogram service: base + "name_lookup_time",
                             metric: curl.name_lookup_time * 1000
        Monitoring.histogram service: base + "connect_time",
                             metric: curl.connect_time * 1000
        Monitoring.histogram service: base + "pre_transfer_time",
                             metric: curl.pre_transfer_time * 1000
        Monitoring.histogram service: base + "start_transfer_time",
                             metric: curl.start_transfer_time * 1000
        Monitoring.histogram service: base + "total_time",
                             metric: curl.total_time * 1000
        # TODO сделать инкрементирующиеся счетчики?
        # curl.downloaded_bytes

        Monitoring.histogram service: base + "download_speed",
                             metric: curl.download_speed
      end

      attach_to :curl

    end
  end
end
