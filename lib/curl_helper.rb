# encoding: utf-8
# helper methods for curb's Curl::Easy
module CurlHelper

  def debug_easy easy
    msg = ""
    msg << " err:#{easy.response_code}" unless easy.response_code == 0 or easy.response_code == 200
    msg << " %dms (p:%dms s:%dms l:%dms c:%dms) dl:%.3fKB (%.3fKB/s)" % [
      easy.total_time * 1000,
      easy.pre_transfer_time * 1000,
      easy.start_transfer_time * 1000,
      easy.name_lookup_time * 1000,
      easy.connect_time * 1000,
      easy.downloaded_bytes / 1000,
      easy.download_speed / 1000
    ]
    msg << " ul:%.3fKB (%.3fKB/s)" % [
      easy.uploaded_bytes / 1000,
      easy.upload_speed / 1000
    ] unless easy.uploaded_bytes == 0
    msg
  end

end
