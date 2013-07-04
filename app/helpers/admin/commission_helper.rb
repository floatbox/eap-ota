# encoding: utf-8
module Admin::CommissionHelper

  def reason_of_disability rule
    return unless rule.disabled?

    if reason = rule.not_implemented
      reason = 'не умеем надежно определять правило' if reason == true
    elsif reason = rule.disabled
      reason = 'причина не указана' if reason == true
    elsif reason = rule.no_commission
      reason = 'продажа по данному правилу запрещена' if reason == true
    end
    " (#{reason}) " if reason
  end

end
