# encoding: utf-8
require 'spec_helper'

# TODO написать rspec_matcher для комиссий, с более внятным выводом причин
describe Commission do

  RSpec::Matchers.define(:match_commission) do |commission|

    match_for_should do |example|
      @recommendation = example.recommendation
      @proposed = Commission.find_for(@recommendation)
      if @proposed != commission
        @reason = commission.turndown_reason(@recommendation)
        false
      else
        true
      end
    end

    match_for_should_not do |example|
      @recommendation = example.recommendation
      @proposed = Commission.find_for(@recommendation)
      !@proposed
    end

    failure_message_for_should do |example|
      if @proposed
        message = "it matched #{@proposed.inspect} instead\n"
      else
        message = "it didn't match anything\n"
      end
      message += "failed to match with reason #{@reason.inspect}\n" if @reason
      message
    end

    failure_message_for_should_not do |example|
      "it matched #{@proposed.inspect}\n"
    end

    description do
      "match commission"
    end
  end

  before do
    Commission.stub(:skip_interline_validity_check).and_return(true)
  end


  Commission.all.each do |commission|


    describe commission.inspect do

      if commission.expired?

        specify {
          pending "expired on #{commission.expr_date}."
        }

      elsif commission.future?

        specify {
          pending "will apply only starting #{commission.strt_date}."
        }

      else

        next if commission.examples.blank?
        commission.examples.each do |example|

          context example.inspect do

            subject {example}

            if commission.disabled?
              it {
                should_not match_commission
              }
            else
              it {
                should match_commission(commission)
              }
            end

          end
        end
      end
    end
  end
end
