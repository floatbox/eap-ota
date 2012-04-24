# encoding: utf-8
class Partner < ActiveRecord::Base

  def initialize(*)
    super
    self.hide_income ||= false
    end

  def self.[] token
    find_by_token token
  end

  def self.authenticate id, pass
    self[id].password == pass if self[id] && pass.present?
  end

  def self.this_name_is_off? name
    !self[name] || !self[name].enabled
  end

  def self.this_name_is_on? name
    self[name] && self[name].enabled
  end
end
