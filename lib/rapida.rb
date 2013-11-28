# encoding: utf-8

class Rapida
  # класс для работы с RapidaCharge и всем-всем-всем

  def check(txn_id, account, sum, phone)
    # заглушка
    'check'
  end

  def pay(txn_id, account, sum, phone)
    # заглушка
    'pay'
  end

  private

  def order?(account)
    @order = Order.where(code: account).first ? true : false
  end

  def error
  end

  def fatal_error
  end
end

