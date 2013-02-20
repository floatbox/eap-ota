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

  def disable!
    update_attributes enabled: false
  end

  def enable!
    update_attributes enabled: true
  end

  def limit! limit=20
    update_attributes suggested_limit: limit
  end

  def logo_url
    "/images/metas/#{token}.png"
  end

  def logo_exist?
    FileTest.exist?(Rails.root.join("public#{logo_url}").to_s)
  end
end
