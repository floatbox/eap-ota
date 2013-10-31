require 'spec_helper'

describe SMS do

  describe '#gate' do

    include SMS

    it { gate.should be_kind_of(SMS::MFMS) }

    it 'should return same gate with same arguments' do
      args = { common: {start_time: Time.now} }
      gate1 = gate(args)
      gate2 = gate(args)
      gate1.should be_equal(gate2)
    end

    it 'should not return same gate with different arguments' do
      args = { common: {start_time: Time.now} }
      gate1 = gate
      gate2 = gate(args)
      gate1.should_not be_equal(gate2)
    end

  end
end
