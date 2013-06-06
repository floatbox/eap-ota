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
    Commission::Rule.stub(:skip_interline_validity_check).and_return(true)
  end


  # будет (и должно!) валиться,
  # если в config/commissions.rb - синтаксическая ошибка.
  Commission.reload!

  book = Commission.default_book
  carriers = book.all_carriers
  carriers.each do |carrier|
    # проверка всех диапазонов дат для авиакомпании
    start_dates = ( book.start_dates_for_carrier(carrier) + [Date.today] ).reject(&:past?).uniq
    # start_dates = [Date.today]

    commissions = book.for_carrier(carrier)

    start_dates.each do |start_date|
      describe "#{carrier} on #{start_date}" do

        before do
          Timecop.freeze(start_date)
        end

        after do
          Timecop.return
        end

        commissions.each do |commission|

          describe commission.inspect do

            if Timecop.freeze(start_date) { commission.applicable_date? }

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
    end
  end
end
