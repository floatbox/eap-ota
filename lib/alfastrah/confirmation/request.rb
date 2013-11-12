module Alfastrah
  module Confirmation
    class Request
      include Virtus.model

      attribute :policy_id, Fixnum

      def endpoint
        'confirmPolicy'
      end

      def build_xml
        x = Builder::XmlMarkup.new
        x.soapenv :Envelope, 'xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:trav' => 'http://vtsft.ru/travelExtService/' do
          x.soapenv :Header
          x.soapenv :Body do
            x.trav :confirmPolicyRequest do
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
