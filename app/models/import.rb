# encoding: utf-8
require 'digest/md5'
class Import < ActiveRecord::Base

  def self.from_file(filepath, kind)
    filename = File.basename(filepath)
    content = File.open(filepath, 'r:binary') { |f| f.read }
    md5 = Digest::MD5.hexdigest(content)
    find_or_create_by_md5(md5, kind: kind, content: content, filename: filename)
  end

  has_and_belongs_to_many :tickets
  has_and_belongs_to_many :payments

  validates :content, :presence => true
  before_save :compute_md5

  def compute_md5
    self.md5 = Digest::MD5.hexdigest(content) if content
    true
  end

end
