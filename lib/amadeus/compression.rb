module Amadeus
  module Compression

    # adding response compression
    def on_after_create_http_request(request)
      request.add_header('Accept-Encoding', 'deflate')
    end

    # залезаем грязными ручками не глядя на заголовки
    def parse_soap_response_document(body)
      super Zlib::Inflate.inflate(body)
    end

  end
end
