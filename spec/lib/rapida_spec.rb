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
  order.save!
  order
end

def check(args)
  rapida = Rapida.new(args)
  check_response = rapida.check
  parse(check_response)
end

def pay(args)
  rapida = Rapida.new(args)
  pay_response = rapida.pay
  parse(pay_response)
end


describe Rapida do
  let(:txn_id) { '1337' }
  let(:phone) { '9998887766' }
  let(:order) { new_order }
  let(:account) { order.code }
  let(:sum) { order.price_with_payment_commission }
  let(:check_args) do
    {
      txn_id: txn_id,
      phone: phone,
      sum: sum,
      account: account
    }
  end

  ### CHECK
  describe '#check' do
    context 'successfull' do
      specify 'all parameters provided' do
        # TODO порефакторить спеку
        parsed = check(check_args)

        parsed.result.should == '0'
        parsed.account.should == account
        parsed.rapida_txn_id.should == txn_id
      end

      specify 'phone not provided' do
        check_args.delete(:phone)
        parsed = check(check_args)

        parsed.result.should == '0'
        parsed.rapida_txn_id.should == txn_id
      end

      context 'payment persistance' do
        before do
          check(check_args)
        end

        specify 'with exactly one payment' do
          payment = order.payments.size.should eq(1)
        end

        context 'with valid values' do
          before do
            @payment = order.payments.last
          end

          subject(:payment) { @payment }

          its(:endpoint_name) { should eq('rapida') }
          its(:price) { should eq(sum) }
          its(:status) { should eq('pending') }
          its(:their_ref) { should eq(txn_id) }
        end
      end
    end

    context 'failed' do
      context 'with wrong parameters' do
        specify 'txn_id not provided' do
          check_args.delete(:txn_id)
          parsed = check(check_args)

          parsed.result.should == '8'
          parsed.account.should == account
        end

        specify 'account not provided' do
          check_args.delete(:account)
          parsed = check(check_args)

          parsed.result.should == '4'
          parsed.rapida_txn_id.should == txn_id
        end

        specify 'sum not provided' do
          check_args.delete(:sum)
          parsed = check(check_args)

          parsed.result.should == '8'
          parsed.rapida_txn_id.should == txn_id
        end

        specify 'more than one mandatory paramater not provided' do
          check_args.delete(:account)
          check_args.delete(:phone)
          check_args.delete(:sum)
          parsed = check(check_args)

          parsed.result.should == '4'
          parsed.rapida_txn_id.should == txn_id
        end
      end

      specify 'on database error' do
        RapidaCharge.stub(:new).and_raise(ActiveRecord::StatementInvalid.new)
        check_args.update(
          account: order.code,
          sum: order.price_with_payment_commission
        )
        parsed = check(check_args)
        parsed.result.should == '1'
      end

      specify 'multiple queries on same txn_id' do
        parsed = nil

        2.times do
          parsed = check(check_args)
        end

        parsed.result.should eq('0')
      end

      context 'with wrong price - ' do
        specify 'price is greater than real' do
          check_args[:sum] = sum + 1
          parsed = check(check_args)

          parsed.result.should == '242'
          parsed.account.should == account
        end

        specify 'price is less than real' do
          check_args[:sum] = sum - 100
          parsed = check(check_args)

          parsed.result.should == '241'
          parsed.account.should == account
        end
      end

      specify 'unknown code' do
        check_args[:account] = 'lulz'
        parsed = check(check_args)

        parsed.result.should == '5'
      end

      specify 'wrong code format' do
        check_args[:account] = 'WRONG🚷'
        parsed = check(check_args)

        parsed.result.should == '4'
      end
    end
  end

  ### PAY
  describe '#pay' do
    let(:txn_date) { '20131104171819' }
    let(:pay_args) do
      {
        txn_id: txn_id,
        phone: phone,
        sum: sum,
        account: account,
        txn_date: txn_date
      }
    end

    before do
      check(check_args)
    end

    context 'successful' do

      specify 'all parameters provided' do
        response = pay(pay_args)

        response.result.should == '0'
        response.rapida_txn_id.should == txn_id
        response.prv_txn.should match(/^#{Conf.rapida.ref_prefix}\d+$/)
      end

      specify 'phone not provided' do
        pay_args.delete(:phone)
        parsed = pay(pay_args)

        parsed.result.should == '0'
        parsed.rapida_txn_id.should == txn_id
      end

      context 'payment persistance' do
        before do
          pay(pay_args)
        end

        specify 'with exactly one payment' do
          payment = order.payments.size.should eq(1)
        end

        context 'with valid values' do
          before do
            @payment = order.payments.last
          end

          subject(:payment) { @payment }

          its(:price) { should eq(sum) }
          its(:status) { should eq('charged') }
          its(:their_ref) { should eq(txn_id) }
          its(:ref) { should match(/^#{Conf.rapida.ref_prefix}\d+$/) }
        end
      end
    end

    context 'failed' do
      context 'with wrong parameters' do
        specify 'txn_id not provided' do
          pay_args.delete(:txn_id)
          parsed = pay(pay_args)

          parsed.result.should == '8'
        end

        specify 'sum not provided' do
          pay_args.delete(:sum)
          parsed = pay(pay_args)

          parsed.result.should == '8'
          parsed.rapida_txn_id.should == txn_id
        end

        specify 'txn_date not provided' do
          pay_args.delete(:txn_date)
          parsed = pay(pay_args)

          parsed.result.should == '8'
          parsed.rapida_txn_id.should == txn_id
        end

        specify 'more than one mandatory paramater not provided' do
          pay_args.delete(:account)
          pay_args.delete(:phone)
          pay_args.delete(:sum)
          parsed = pay(pay_args)

          parsed.result.should == '4'
          parsed.rapida_txn_id.should == txn_id
        end
      end

      specify 'not authorized with "check" query' do
        order = new_order
        parsed = pay(
          txn_id: txn_id,
          phone: phone,
          sum: order.price_with_payment_commission,
          account: order.code,
          txn_date: txn_date
        )
        parsed.result.should_not == '0'
      end

      specify 'paid already' do
        parsed = nil
        2.times { parsed = pay(pay_args) }

        parsed.result.should == '10'
      end
    end
  end
end

