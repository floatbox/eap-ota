# encoding: utf-8

module PartnerTracking

  protected

  # before filter
  def save_partner_cookies
    track_partner params[:partner], params[:marker]
  end

  def track_partner new_partner, new_marker=nil
    return unless new_partner.present?
    if partner != new_partner
      StatCounters.inc %W[enter.api.first_time enter.api.#{new_partner}.first_time]
      logger.info "API::Partner::Enter: #{new_partner} #{new_marker}"
    end
    if Partner[new_partner].track?
      set_partner_cookies(new_partner, new_marker, Partner[new_partner].cookies_expiry_time || Partner.default_expiry_time)
    end
  end

  def set_partner_cookies(partner, marker, days_to_remember)
    Conf.api.url_base =~ /https?:\/\/([\w\.]+)\/?/
    domain = ".#{$1}"
    # возможно стоит юзать session_store ..., domain: :all
    # для того чтобы избежать этой проблемы в дальнейшем
    cookies[:partner] = { value: partner, expires: days_to_remember.days.from_now, domain: domain }
    # маркер надо перезатирать, даже если его не указали
    cookies[:marker] = { value: marker, expires: days_to_remember.days.from_now, domain: domain }
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
