# encoding: utf-8
class Partner < ActiveRecord::Base

  has_paper_trail

  def initialize(*)
    super
    self.hide_income ||= false
    self.enabled ||= false
    self.password ||= ''
  end

  # ставить ли куку?
  # у анонимуса нет токена
  def track?
    token != ''
  end

  # сколько дней помнить партнера, если не проставлено в базе
  def self.default_expiry_time; 1; end

  def self.[] token
    find_by_token(token) || anonymous
  end

  def self.anonymous
    find_or_create_by_token('')
  end

  def self.authenticate id, pass
    self[id].password == pass if pass.present?
  end
end
