# encoding: utf-8
require 'spec_helper'

# TODO написать rspec_matcher для комиссий, с более внятным выводом причин
describe Commission do

  before do
    Commission.stub(:skip_interline_validity_check).and_return(true)
  end

  Commission.all.each do |commission|

    context "##{commission.number} for carrier #{commission.carrier} on line #{commission.source}" do
      if commission.expired?

        pending "expired on #{commission.expr_date}."

      elsif commission.future?

        pending "will apply only starting #{commission.strt_date}."

      else

        next if commission.examples.blank?
        commission.examples.each do |code, source|

          context "example '#{code}'" do

            let (:rec) { Recommendation.example(code, :carrier => commission.carrier) }
            let (:proposed) { Commission.find_for(rec) }

            if commission.disabled?

              it "is disabled and should not match anything" do
                proposed.should be_nil
              end

            else

              it "should match" do
                commission.turndown_reason(rec).should be_nil
                proposed.should == commission
              end

            end
          end
        end
      end
    end
  end
end
