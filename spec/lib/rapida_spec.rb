# encoding: utf-8

require 'spec_helper'
require 'rapida'

def parse(response)
  xml = Nokogiri::XML(response)
  response_tags = xml.at('response').children
  response_tags.inject(OpenStruct.new) do |acc, elem|
    acc.__send__(:"#{elem.name}=", elem.text)
    acc
  end
end

def new_order
  order = build(:order)
  yield(order) if block_given?
  order.save!
  order
end

def check(*args)
  rapida = Rapida.new(*args)
  check_response = rapida.check
  parsed = parse(check_response)
end

def pay(*args)
  rapida = Rapida.new(*args)
  check_response = rapida.pay
  parsed = parse(check_response)
end


describe Rapida do

  let(:txn_id) { '1337' }
  let(:phone) { '9998887766' }

  describe '#check' do

    let(:order) { new_order }
    let(:account) { order.code }
    let(:price) { order.price_with_payment_commission }

    context 'successfull' do

      specify 'all parameters provided' do
        # TODO порефакторить спеку
        parsed = check(txn_id, account, price, phone)
        parsed.result.should == '0'
        parsed.account.should == account
        parsed.rapida_txn_id.should == txn_id
      end

      specify 'phone not provided' do
        parsed = check(txn_id, account, price, nil)

        parsed.result.should == '0'
        parsed.rapida_txn_id.should == txn_id
      end

    end

    context 'failed' do

      context 'with wrong parameters' do

        specify 'txn_id not provided' do
          parsed = check(nil, account, price, phone)

          parsed.result.should == '8'
          parsed.account.should == account
        end

        specify 'account not provided' do
          parsed = check(txn_id, nil, price, phone)

          parsed.result.should == '8'
          parsed.rapida_txn_id.should == txn_id
        end

        specify 'more than one mandatory paramater not provided' do
          parsed = check(txn_id, nil, nil, nil)

          parsed.result.should == '8'
          parsed.rapida_txn_id.should == txn_id
        end
      end

      context 'with wrong price' do

        specify 'price is greater than real' do
          parsed = check(txn_id, account, price + 1, phone)

          parsed.result.should == '242'
          parsed.account.should == account
        end

        specify 'price is less than real' do
          parsed = check(txn_id, account, price - 100, phone)

          parsed.result.should == '241'
          parsed.account.should == account
        end

      end

    end

  end

  describe '#pay' do
  end

end

