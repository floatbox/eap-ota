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
    self.ref = Conf.rapida.ref_prefix + self.id.to_s if persisted?
  end

end

