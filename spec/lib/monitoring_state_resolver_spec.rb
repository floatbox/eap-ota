#encoding: utf-8
require 'spec_helper'

describe Monitoring::StateResolver do

  let(:event){{service: 'test', metric: 5}}
  subject {described_class.new(event)}

  context 'for service not present in states file' do
    let(:event){{service: 'missing', metric: 5}}

    its(:state){should == 'ok'}
  end

  context 'for event without service field' do
    let(:event){{metric: 5}}

    its(:state){should == 'ok'}
  end

  context 'for event present in states file' do
    context 'when metric is less than warning threshold' do
      let(:event){{service: 'Pricer_async_total', metric: 100}}

      its(:state){should == 'ok'}
    end

    context 'when metric is less than error threshold' do
      let(:event){{service: 'Pricer_async_total', metric: 12510}}

      its(:state){should == 'warning'}
    end

    context 'when metric is more than error threshold' do
      let(:event){{service: 'Pricer_async_total', metric: 26000}}

      its(:state){should == 'error'}
    end

    context 'when metric is not present' do
      let(:event){{service: 'Pricer_async_total'}}

      its(:state){should == 'ok'}
    end
  end
end
