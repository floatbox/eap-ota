# encoding: utf-8

module PartnerTracking

  def track_partner new_partner, new_marker=nil
    return unless new_partner
    unless partner
      StatCounters.inc %W[enter.api.first_time enter.api.#{new_partner}.first_time]
      logger.info "API::Partner::Enter: #{new_partner} #{new_marker}"
    end
    cookies[:partner] = { :value => new_partner, :expires => 1.month.from_now}
    # маркер надо перезатирать, даже если его не указали
    cookies[:marker] = { :value => new_marker, :expires => 1.month.from_now}
  end

  def partner
    cookies[:partner]
  end

  def marker
    cookies[:marker]
  end

  def log_partner
    logger.info "API::Partner: #{partner} #{marker}" if partner
  end
end
