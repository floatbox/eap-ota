# encoding: utf-8
require 'spec_helper'

describe Context do
  describe "#initialize" do
    it "won't fail" do
      Context.new( deck_user: Deck::User.new )
    end
  end

  describe "#pricer_sort?" do
    it do
      build(:context).pricer_sort?.should == true
    end
    it do
      build(:context, :deck_user).pricer_sort?.should == true
    end
    it do
      build(:context, :partner, :deck_user).pricer_sort?.should == true
    end
    it do
      build(:context, :robot, :deck_user).pricer_sort?.should == false
    end
    it do
      build(:context, :robot).pricer_sort?.should == false
    end
    it do
      build(:context, :robot, :partner, :deck_user).pricer_sort?.should == false
    end
    it do
      build(:context, :robot, :partner).pricer_sort?.should == false
    end
    it do
      build(:context, :robot, :deck_user, :disabled_partner).pricer_sort?.should == false
    end
    it do
      build(:context, :robot, :disabled_partner).pricer_sort?.should == false
    end
  end

  describe "#pricer_filter?" do
    it do
      build(:context).pricer_filter?.should == true
    end
    it do
      build(:context, :deck_user).pricer_filter?.should == false
    end
    it do
      build(:context, :partner).pricer_filter?.should == true
    end
    it do
      build(:context, :deck_user, :partner).pricer_filter?.should == false
    end
    it do
      build(:context, :robot, :deck_user).pricer_filter?.should == false
    end
    it do
      build(:context, :robot).pricer_filter?.should == true
    end
    it do
      build(:context, :robot, :partner, :deck_user).pricer_filter?.should == false
    end
    it do
      build(:context, :robot, :partner).pricer_filter?.should == true
    end
    it do
      build(:context, :robot, :disabled_partner).pricer_filter?.should == true
    end
  end

  describe "#pricer_suggested_limit" do
    before do
      Partner.anonymous.update_attribute :suggested_limit, 77
    end

    context "when Partner#anonymous has suggested_limit" do
      it do
        build(:context).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :deck_user).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :limited_partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :deck_user, :partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :robot).pricer_suggested_limit.should == Partner.anonymous.suggested_limit
      end
      it do
        build(:context, :robot, :deck_user).pricer_suggested_limit.should == Partner.anonymous.suggested_limit
      end
      it do
        build(:context, :robot, :partner).pricer_suggested_limit.should == Partner.anonymous.suggested_limit
      end
      it do
        build(:context, :robot, :limited_partner).pricer_suggested_limit.should == 20
      end
      it do
        build(:context, :robot, :deck_user, :partner).pricer_suggested_limit.should == Partner.anonymous.suggested_limit
      end
      it do
        build(:context, :robot, :deck_user, :limited_partner).pricer_suggested_limit.should == 20
      end
    end

    context "when Partner#anonymous has no suggested_limit" do
      before do
        Partner.anonymous.update_attribute :suggested_limit, nil
      end

      it do
        build(:context).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :deck_user).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :limited_partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :deck_user, :partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_full
      end
      it do
        build(:context, :robot).pricer_suggested_limit.should == Conf.amadeus.recommendations_lite
      end
      it do
        build(:context, :robot, :deck_user).pricer_suggested_limit.should == Conf.amadeus.recommendations_lite
      end
      it do
        build(:context, :robot, :partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_lite
      end
      it do
        build(:context, :robot, :limited_partner).pricer_suggested_limit.should == 20
      end
      it do
        build(:context, :robot, :deck_user, :partner).pricer_suggested_limit.should == Conf.amadeus.recommendations_lite
      end
      it do
        build(:context, :robot, :deck_user, :limited_partner).pricer_suggested_limit.should == 20
      end
    end
  end
end
