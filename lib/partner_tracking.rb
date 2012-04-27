# encoding: utf-8

module PartnerTracking

  def track_partner new_partner, new_marker=nil
    @new_partner, @new_marker = new_partner, new_marker
    return unless @new_partner
    unless partner
      StatCounters.inc %W[enter.api.first_time enter.api.#{@new_partner}.first_time]
      logger.info "API::Partner::Enter: #{@new_partner} #{@new_marker}"
    end
    if Partner[@new_partner] && Partner[@new_partner].cookies_expiry_time
      set_cookies
    elsif Partner[@new_partner] && !Partner[@new_partner].cookies_expiry_time
      we_want_change_nil
      set_cookies
    end
  end

  def set_cookies
   cookies[:partner] = { :value => @new_partner, :expires => Partner[@new_partner].cookies_expiry_time.days.from_now}
   # маркер надо перезатирать, даже если его не указали
   cookies[:marker] = { :value => @new_marker, :expires => Partner[@new_partner].cookies_expiry_time.days.from_now}
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

  def we_want_change_nil
    Partner[@new_partner].update_attributes(:cookies_expiry_time => 1) if @new_partner.present?
  end
end
