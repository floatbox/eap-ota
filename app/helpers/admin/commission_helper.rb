# encoding: utf-8
module Admin::CommissionHelper

  def reason_of_disability commission
    return unless commission.disabled?

    if reason = commission.not_implemented
      if reason == true
        reason = 'не умеем надежно определять правило'
      end
    elsif reason = commission.disabled
      if reason == true
        reason = 'причина не указана'
      end
    elsif commission.no_commission
      reason = 'заглушка для спорных предложений'
    end
    " (#{reason}) " if reason
  end

end
