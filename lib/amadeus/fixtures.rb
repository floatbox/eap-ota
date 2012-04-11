module Amadeus::Fixtures
  # Угадывает имя класса по первым двум составляющим имени фикстуры
  # let(:pnr_resp) { amadeus_response 'spec/amadeus/xml/PNR_Retrieve_with_four_tickets.xml' }
  # имя фикстуры должно быть формата '**/PNR_Retrieve_*' для класса PNRRetrieve
  def amadeus_response(filename)
    base = filename.split('/').last

    body = File.read(filename)
    doc = Amadeus::Service.parse_string(body)

    class_name = base.split(/[_.]/)[0,2].join
    klass = "Amadeus::Response::#{class_name}".constantize
    klass.new(doc)
  end
end
