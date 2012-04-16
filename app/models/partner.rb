# encoding: utf-8
class Partner < ActiveRecord::Base

  def self.authenticate id, pass
    self.find_by_token(id).password == pass if self.find_by_token(id) && pass.present?
  end

  def self.this_name_is_off? name
    !self.find_by_token(name) || !self.find_by_token(name).enabled
  end

  def self.this_name_is_on? name
    self.find_by_token(name) && self.find_by_token(name).enabled
  end
end