# encoding: utf-8

module SMS
  module Gate
    class MFMS < SMS::Gate::Base

      class SMSError < StandardError; end

      def initialize(hash = {})
        @login = hash[:login] || 'eviterra0'
        @password = hash[:password] || 'Fk3e8wQa'
        @common = hash[:common]
        super
      end

      # Принимает либо хеш с параметрами смс,
      # либо Enumerable таких хешей
      # В любом случае отправляет одним запросом.
      def send_sms(params)
        case params
          when Hash then send_one(params)
          when Enumerable then send_multiple(params)
        end
      rescue SMSError => e
        with_warning(e)
      end


      private

      def send_one(hash)
        xml = compose([hash])
        response = invoke_post_request(xml)
      end

      def send_multiple(messages)
        xml = compose(messages)
        response = invoke_post_request(xml)
      end

      def compose(messages)
        Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
          # все теги заканчиваются на _,
          # _ убирается из итоговой xml и используется в Nokogiri чтобы не путать с методами

          xml.consumeOutMessageRequest_ {

            xml.header_ {
              xml.auth_ {
                xml.login_    @login
                xml.password_ @password
              }
            }

            xml.payload_ {
              xml.outMessageCommon_ {
                if @common
                  compose_message(xml, @common)
                end
              }

              xml.outMessageList_ {
                messages.each_with_index { |message, index|
                  # TODO тут cliendId это тупо 0-based индекс,
                  # уточнить потом и исправить, если надо
                  xml.outMessage_(cliendId: index) {
                    compose_message(xml, message)
                  }
                }
              }

            }
          }
        end.to_xml.tap { |x| p "request: #{x}" }
      end

      def compose_message(xml, message)
        Rails.logger.info "message: #{message}"
        xml.address_               message[:address]                if message[:address]
        xml.startTime_             message[:start_time]             if message[:start_time]
        xml.validityPeriodMinutes_ message[:validity_period]        if message[:validity_period]
        xml.content_               message[:content]                if message[:content]
        xml.comment_               message[:comment]                if message[:comment]
        xml.priority_              (message[:priority] || 'medium') if message[:priority]
        xml.subject_               'Eviterra'                       if message[:subject]
        xml.contentType_           'text'
      end

      def parse_response(response)
        xml = Nokogiri::XML(response.body)
        p "xml: #{xml}"

        code = xml.xpath('/consumeOutMessageResponse/payload/code').text
        fail SMSError, "SMS not sent, error_code received: #{code}" unless code == 'ok'

        parsed_response = Hash.new do |hash|
          xml.xpath('consumeOutMessageResponse/payload/outMessageList//outMessage').map do |message|
            client_id = message.attr('clientId')
            provider_id = message.attr('providerId')
            code = message('./code')
            if code == 'ok'
              hash[client_id] = {provider_id: provider_id, code: code}
            end
          end
        end
      end

      def convert_date(date)
        date.strftime('%Y-%m-%d %H:%M:%S')
      end

    end
  end
end

