class Alfastrah
  module Info
    class Request < Alfastrah::Base::Request
      attribute :policy_id, Fixnum
      validates :policy_id, presence: true, allow_blank: false

      def endpoint
        'getPolicy'
      end

      def build_xml
        x = Builder::XmlMarkup.new
        x.soapenv :Envelope, 'xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:trav' => 'http://vtsft.ru/travelExtService/' do
          x.soapenv :Header
          x.soapenv :Body do
            x.trav :getPolicyRequest do
              x.trav :operator do
                x.trav :code, 'eviterra'
              end
              x.trav :policyId, policy_id
            end
          end
        end
      end
    end
  end
end
