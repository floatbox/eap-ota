ActiveAdmin.register CurrencyRate, as: "Rate" do
  scope :all, default: true
  scope :cbr
  scope :amadeus
  config.sort_order = "date_desc"

  index do
    column :bank
    column :date
    column :from
    column :to
    column :rate
    actions
  end

  filter :date
  filter :from, as: :select, collection: CurrencyRate.currencies
  filter :to, as: :select, collection: CurrencyRate.currencies
end
