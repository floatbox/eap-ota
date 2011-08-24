# encoding: utf-8

require 'spec_helper'

describe CommissionRules do

  class TestCommission
    include CommissionRules

    carrier 'FV'
    commission '2%/3'

  end

  describe TestCommission do
    specify do
      TestCommission.find_for( Recommendation.example('SVOCDG', :carrier => 'FV') ).should be_a(TestCommission)
    end
  end

end
