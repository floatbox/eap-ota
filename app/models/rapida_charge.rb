# encoding: utf-8

class RapidaCharge < Payment

  # распределение дохода
  def set_defaults
    self.endpoint_name = 'rapida'
    self.commission = Conf.rapida.commission if commission.blank?
    self
  end

end

