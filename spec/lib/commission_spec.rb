# encoding: utf-8
require 'spec_helper'

# TODO написать rspec_matcher для комиссий, с более внятным выводом причин
describe Commission, :commissions do

  RSpec::Matchers.define(:match_rule) do |page, rule|

    match_for_should do |example|
      @recommendation = example.recommendation
      @proposed = page.find_rule_for_rec(@recommendation)
      if @proposed != rule
        @reason = rule.turndown_reason(@recommendation)
        false
      else
        true
      end
    end

    match_for_should_not do |example|
      @recommendation = example.recommendation
      @proposed = page.find_rule_for_rec(@recommendation)
      @proposed.nil? || !@proposed.sellable?
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
      "match rule"
    end
  end

  # будет (и должно!) валиться,
  # если в config/commissions.rb - синтаксическая ошибка.
  Commission.reload!

  book = Commission.default_book
  book.pages.each do |page|

    describe "#{page.carrier},#{page.ticketing_method} on #{page.start_date || 'beginning of time'}" do
      page.rules.each do |rule|

        describe rule.inspect do

          if rule.skipped?
            specify { pending "disabled or not implemented, skipping examples" }
            next
          end

          unless rule.disabled?
            it "should have ticketing method" do
              rule.ticketing_method.should_not be_nil
            end
          end

          if rule.examples.blank?
            specify { pending "no examples" }
            next
          end

          rule.examples.each do |example|

            context example.inspect do

              subject {example}

              if rule.disabled?
                it {
                  should_not match_rule(page)
                }
              else
                it {
                  should match_rule(page, rule)
                }
              end

            end
          end
        end
      end
    end
  end
end
