# encoding: utf-8

class RapidaRefund < Payment

  # TODO в Payment поднять пора такую штуку
  def generate_ref
    Conf.rapida.ref_refund_prefix + id.to_s if persisted?
  end

end

