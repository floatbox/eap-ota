# encoding: utf-8
RSpec::Matchers.define :have_errors_on do |attribute|
  match do |model|
    # call it here so we don't have to write it in before blocks
    model.valid?
    model.errors.has_key?(attribute)
  end
end
