# encoding: utf-8

module PartnerModule

  def track_partner partner, marker=nil
    unless cookies[:partner]
      StatCounters.inc %W[enter.api.first_time enter.api.#{partner}.first_time]
      logger.info "API::Partner::Enter: #{partner} #{Time.now}"
      logger.info "API::Marker::Enter: #{marker} #{Time.now}"
    end
    cookies[:partner] = { :value => partner, :expires => Time.now + 3600*24*30}
    cookies[:marker] = { :value => marker, :expires => Time.now + 3600*24*30} if marker
  end

  def check_partner
    cookies[:partner][:value]
  end

  def check_marker
    cookies[:marker][:value]
  end

  def log_partner
    logger.info "API::Partner: #{cookies[:partner][:value]}" if cookies[:partner]
  end

  def log_marker
    logger.info "API::Marker: #{cookies[:marker][:value]}" if cookies[:marker]
  end
end