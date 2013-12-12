# encoding: utf-8

class RapidaCharge < Payment

  # распределение дохода
  def set_defaults
    self.endpoint_name = 'rapida'
    self.commission = Conf.rapida.commission if commission.blank?
    self
  end

  # TODO в Payment поднять пора такую штуку
  def generate_ref
    Conf.rapida.ref_prefix + id.to_s if persisted?
  end

  def charge!
    # все проверки сейчас делаются в Rapida
    update_attributes(status: 'charged')
  end

  # TODO поднять проверялки статусов в Payment
  def pending?
    payment_status == 'pending'
  end

  def charged?
    payment_status == 'charged'
  end

end

