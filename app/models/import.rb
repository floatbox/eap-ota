# encoding: utf-8
require 'digest/md5'
class Import < ActiveRecord::Base
  # belongs_to :ticket

  validates :content, :presence => true
  before_save :compute_md5

  def compute_md5
    self.md5 = Digest::MD5.hexdigest(content) if content
    true
  end

end
