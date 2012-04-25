# encoding: utf-8

module PartnerTracking

  def track_partner new_partner, new_marker=nil
    return unless new_partner
    unless partner
      StatCounters.inc %W[enter.api.first_time enter.api.#{new_partner}.first_time]
      logger.info "API::Partner::Enter: #{new_partner} #{new_marker}"
    end
    if Partner[new_partner] && Partner[new_partner].cookies_expiry_time
      cookies[:partner] = { :value => new_partner, :expires => Partner[new_partner].cookies_expiry_time.days.from_now}
      # маркер надо перезатирать, даже если его не указали
      cookies[:marker] = { :value => new_marker, :expires => Partner[new_partner].cookies_expiry_time.days.from_now}
    end
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
