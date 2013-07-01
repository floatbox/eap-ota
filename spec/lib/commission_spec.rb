# encoding: utf-8
require 'spec_helper'

# TODO написать rspec_matcher для комиссий, с более внятным выводом причин
describe Commission do

  RSpec::Matchers.define(:match_commission) do |page, commission|

    match_for_should do |example|
      @recommendation = example.recommendation
      @proposed = page.find_commission(@recommendation)
      if @proposed != commission
        @reason = commission.turndown_reason(@recommendation)
        false
      else
        true
      end
    end

    match_for_should_not do |example|
      @recommendation = example.recommendation
      @proposed = page.find_commission(@recommendation)
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
    Commission::Rule.stub(:skip_interline_validity_check).and_return(true)
  end


  # будет (и должно!) валиться,
  # если в config/commissions.rb - синтаксическая ошибка.
  Commission.reload!

  book = Commission.default_book
  book.pages.each do |page|

    describe "#{page.carrier} on #{page.strt_date || 'beginning of time'}" do
      page.commissions.each do |commission|

        describe commission.inspect do

          if commission.examples.blank?
            specify { pending "no examples" }
            next
          end

          commission.examples.each do |example|

            context example.inspect do

              subject {example}

              if commission.disabled?
                it {
                  should_not match_commission(page)
                }
              else
                it {
                  should match_commission(page, commission)
                }
              end

            end
          end
        end
      end
    end
  end
end
