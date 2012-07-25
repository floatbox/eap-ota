# encoding: utf-8
module Admin::CommissionHelper

  def reason_of_disability commission
    return unless commission.disabled?

    if reason = commission.not_implemented
      reason = 'не умеем надежно определять правило' if reason == true
    elsif reason = commission.disabled
      reason = 'причина не указана' if reason == true
    elsif reason = commission.no_commission
      reason = 'продажа по данному правилу запрещена' if reason == true
    end
    " (#{reason}) " if reason
  end

end
