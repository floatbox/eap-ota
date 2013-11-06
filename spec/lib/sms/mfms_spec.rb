require 'spec_helper'


describe SMS::MFMS do
  # больше ради примеров протокола, чем настоящего тестирования

  describe '#parse_response' do

    def mfms_response(name)
      OpenStruct.new body: open("spec/lib/sms/xml/response/#{name}.xml", 'r').read
    end

    it 'should parse one message response' do

      response = mfms_response(:one_ok)
      result = subject.instance_eval { parse_response(response) }

      result.should == { "2" => { provider_id: "12", code: "ok" } }

    end

    it 'should parse multiple message response' do

      response = mfms_response(:multiple_ok)
      result = subject.instance_eval { parse_response(response) }

      result.should == {
        "3"=>{:provider_id=>"14", :code=>"ok"},
        "4"=>{:provider_id=>"16", :code=>"ok"}
      }

    end

    it 'should raise with non-ok response' do
      response = mfms_response(:general_fail)
      expect { SMS::MFMS.new.instance_eval { parse_response(response) } }.to raise_error(SMS::MFMS::SMSError)
    end

    it 'should parse return partially sent package' do
      response = mfms_response(:partial_fail)
      result = subject.instance_eval { parse_response(response) }

      result.should == {
        "3"=>{:provider_id=>"14", :code=>"error-out-message-client-id-not-unique"},
        "5"=>{:provider_id=>"20", :code=>"ok"}
      }
    end

  end

  describe '#compose_send' do

    def mfms_request(name)
      Nokogiri::XML(open("spec/lib/sms/xml/request/#{name}.xml", 'r').read).to_xml
    end

    let(:time) { DateTime.parse('2013-10-30 18:31:39').to_time }
    let(:test_message1) {
      {
        address: '79998887766',
        content: 'test',
        subject: 'Eviterra',
        comment: 'ok',
        start_time: time,
        client_id: '3'
      }
    }
    let(:test_message2) {
      {
        address: '79998887766',
        content: 'test2',
        subject: 'Eviterra',
        comment: 'ok',
        start_time: time,
        client_id: '4'
      }
    }
    let(:test_message3) {
      {
        address: '79998887766',
        start_time: time,
        client_id: '4',
        content: 'pink fluffy unicorn dancing on rainbow'
      }
    }
    let(:common) {
      { subject: 'Eviterra', comment: 'wow', }
    }
    let(:login) { 'elf' }
    let(:password) { 'cookie' }

    subject { SMS::MFMS.new(login: login, password: password) }

    it 'should correctly compose one message request' do
      request = mfms_request(:one_message)
      messages = [test_message1]
      Nokogiri::XML(subject.instance_eval { compose_send(messages) }).to_xml.should == request
    end

    it 'should correctly compose multiple message request' do
      request = mfms_request(:multiple_messages)
      messages = [test_message1, test_message2]
      Nokogiri::XML(subject.instance_eval { compose_send(messages) }).to_xml.should == request
    end

    it 'should correctly compose request with common context' do
      request = mfms_request(:common_context)
      messages = [test_message3]
      Nokogiri::XML(SMS::MFMS.new(login: login, password: password, common: common).instance_eval { compose_send(messages) }).to_xml.should == request
    end

  end

end

