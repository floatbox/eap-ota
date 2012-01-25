# encoding: utf-8

module PartnerTracking

  def track_partner partner, marker=nil
    unless cookies[:partner]
      StatCounters.inc %W[enter.api.first_time enter.api.#{partner}.first_time]
      logger.info "API::Partner::Enter: #{partner} #{marker}"
    end
    cookies[:partner] = { :value => partner, :expires => 1.month.from_now}
    cookies[:marker] = { :value => marker, :expires => 1.month.from_now} if marker
  end

  def get_partner
    cookies[:partner][:value] if cookies[:partner]
  end

  def get_marker
    cookies[:marker][:value] if cookies[:marker]
  end

  def log_partner
    logger.info "API::Partner: #{get_partner} #{get_marker}" if get_partner
  end
end