# encoding: utf-8
# стырено у активмерчанта
require 'time'
require 'date'
require 'billing/expiry_date'

# == Description
# This credit card object can be used as a stand alone object. It acts just like an ActiveRecord object
# but doesn't support the .save method as its not backed by a database.
#
# For testing purposes, use the 'bogus' credit card type. This card skips the vast majority of
# validations. This allows you to focus on your core concerns until you're ready to be more concerned
# with the details of particular creditcards or your gateway.
#
# == Testing With CreditCard
# Often when testing we don't care about the particulars of a given card type. When using the 'test'
# mode in your Gateway, there are six different valid card numbers: 1, 2, 3, 'success', 'fail',
# and 'error'.
#
#--
# For details, see CreditCardMethods#valid_number?
#++
#
# == Example Usage
#   cc = CreditCard.new(
#     :first_name => 'Steve',
#     :last_name  => 'Smith',
#     :month      => '9',
#     :year       => '2010',
#     :type       => 'visa',
#     :number     => '4242424242424242'
#   )
#
#   cc.valid? # => true
#   cc.display_number # => XXXX-XXXX-XXXX-4242
#
class CreditCard
  include Billing::CreditCardMethods
  include ActiveModel::Validations
  include KeyValueInit

  # FIXME before_validate по идее должен бы вызываться в недрах ActiveModel
  # FIXME заменить на ActiveModel колбэки или что там
  def valid?
    super
    before_validate
    validate
    errors.empty?
  end

  ## Attributes

  cattr_accessor :require_verification_value
  self.require_verification_value = true

  # Essential attributes for a valid, non-bogus creditcards
  attr_accessor :month, :year, :type, :first_name, :last_name, :name
  attr_writer :number, :number1, :number2, :number3, :number4

  # Required for Switch / Solo cards
  attr_accessor :start_month, :start_year, :issue_number
  attr_reader :year_short

  # Optional verification_value (CVV, CVV2 etc). Gateways will try their best to
  # run validation on the passed in value if it is supplied
  attr_accessor :verification_value

  # Provides proxy access to an expiry date object
  def expiry_date
    Billing::ExpiryDate.new(@month, @year)
  end

  def year_short= (y)
    @year_short = y
    @year = '20' + y if y.present?
  end

  def number
    numbers = [@number1, @number2, @number3, @number4]
    (numbers.all? && numbers.every.to_s.join) || @number
  end

  #для сохранения обратной совместимости остался и старый attr_writer :number
  def number1
    @number1 || (@number && @number.length == 16 && @number[0..3])
  end

  def number2
    @number2 || (@number && @number.length == 16 && @number[4..7])
  end

  def number3
    @number3 || (@number && @number.length == 16 && @number[8..11])
  end

  def number4
    @number4 || (@number && @number.length == 16 && @number[12..15])
  end

  def expired?
    expiry_date.expired?
  end

  def name?
    first_name? && last_name?
  end

  def first_name?
    !@first_name.blank?
  end

  def last_name?
    !@last_name.blank?
  end

  def verification_value?
    !@verification_value.blank?
  end

  # Show the card number, with all but last 4 numbers replace with "X". (XXXX-XXXX-XXXX-4338)
  def display_number
    self.class.mask(number)
  end

  def last_digits
    self.class.last_digits(number)
  end

  def validate
    validate_essential_attributes

    # Bogus card is pretty much for testing purposes. Lets just skip these extra tests if its used
    return if type == 'bogus' && Conf.payment.skip_checksum_validation

    validate_card_type
    validate_card_number
    validate_verification_value
    validate_switch_or_solo_attributes
  end

  def self.requires_verification_value?
    require_verification_value
  end

  private

  def before_validate #:nodoc:
    self.month = month.to_i
    self.year  = year.to_i
    self.start_month = start_month.to_i unless start_month.nil?
    self.start_year = start_year.to_i unless start_year.nil?
    self.number = number.to_s.gsub(/[^\d]/, "")
    self.type.downcase! if type.respond_to?(:downcase)
    self.type = self.class.type?(number) if type.blank?
  end

  def validate_card_number #:nodoc:
    errors.add :number, "неверный номер карты" unless CreditCard.valid_number?(number)
    unless errors[:number].present? || errors[:type].present?
      errors.add :type, "is not the correct card type" unless CreditCard.matching_type?(number, type)
    end
  end

  def validate_card_type #:nodoc:
    errors.add :type, "is required" if type.blank?
    errors.add :type, "is invalid"  unless CreditCard.card_companies.keys.include?(type)
  end

  def validate_essential_attributes #:nodoc:
    errors.add :month,      "is not a valid month" unless valid_month?(@month)
    errors.add :year,       "expired"              if expired?
    errors.add :year,       "is not a valid year"  unless valid_expiry_year?(@year)
  end

  def validate_switch_or_solo_attributes #:nodoc:
    if %w[switch solo].include?(type)
      unless valid_month?(@start_month) && valid_start_year?(@start_year) || valid_issue_number?(@issue_number)
        errors.add :start_month,  "is invalid"      unless valid_month?(@start_month)
        errors.add :start_year,   "is invalid"      unless valid_start_year?(@start_year)
        errors.add :issue_number, "cannot be empty" unless valid_issue_number?(@issue_number)
      end
    end
  end

  def validate_verification_value #:nodoc:
    if CreditCard.requires_verification_value?
      errors.add :verification_value, "is required" unless verification_value?
    end
  end
end
