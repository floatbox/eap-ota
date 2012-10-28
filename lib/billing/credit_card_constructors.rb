module Billing
  module CreditCardConstructors

    # CreditCard.example("5486732058864471 123 12/15 No Name")
    #
    def example(str)
      number, cvc, slashed_date, name = str.split(' ', 4)
      month, year = slashed_date.split('/').map(&:to_i)
      name ||= "not specified"
      year += 2000 if year < 2000
      new(
        number: number,
        verification_value: cvc,
        year: year,
        month: month,
        name: name
      )
    end
  end
end
