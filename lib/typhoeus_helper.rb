# encoding: utf-8
module TyphoeusHelper

  class HTTPError < RuntimeError
  end

  # обрабатывает Typhoeus::Response
  def raise_if_error(response)
    raise HTTPError, "Timed out" if response.timed_out?
    raise HTTPError, response.curl_error_message unless response.curl_return_code == 0
    raise HTTPError, "(#{response.code}) #{response.status_message}" unless response.success?
  end
end
