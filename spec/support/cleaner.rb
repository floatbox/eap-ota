# encoding: utf-8

RSpec.configure do |config|
  config.after(:all) do
    # почему-то сохраняет транзакции внутри before(:all) блоков
    Order.delete_all
    Ticket.delete_all
  end
end
