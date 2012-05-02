# encoding: utf-8

module PartnerTracking

  protected

  def track_partner new_partner, new_marker
    return unless new_partner.present?
    unless partner
      StatCounters.inc %W[enter.api.first_time enter.api.#{new_partner}.first_time]
      logger.info "API::Partner::Enter: #{new_partner} #{new_marker}"
    end
    if Partner[new_partner].track?
      set_partner_cookies(new_partner, new_marker, Partner[new_partner].cookies_expiry_time || Partner.default_expiry_time)
    end
  end

  def set_partner_cookies(partner, marker, days_to_remember)
   cookies[:partner] = { :value => partner, :expires => days_to_remember.days.from_now}
   # маркер надо перезатирать, даже если его не указали
   cookies[:marker] = { :value => marker, :expires => days_to_remember.days.from_now}
  end

  def partner
    cookies[:partner]
  end

  def marker
    cookies[:marker]
  end

  def log_partner
    logger.info "API::Partner: #{partner} #{marker}" if partner.present?
  end
end
