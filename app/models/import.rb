# encoding: utf-8
require 'digest/md5'
require 'pathname'
require 'zip'
require 'tempfile'
class Import < ActiveRecord::Base

  # Dir[base + '/**/*'].each do |path|
  #   next if File.directory? path
  #   Import.from_file('air', path, basedir: base)
  # end

  def self.from_file(kind, filepath, opts={})
    return from_zipfile(kind, filepath) if filepath =~ /.zip$/
    basedir = opts[:basedir]
    filename =
      if basedir
        Pathname(filepath).relative_path_from( Pathname(basedir) ).to_s
      else
        File.basename(filepath)
      end
    created_at = File.ctime(filepath)
    content = File.read(filepath, encoding: 'binary')
    find_or_create_by_content(content, kind: kind, filename: filename, created_at: created_at)
  end

  def self.from_zipfile(kind, filepath)
    basename = File.basename(filepath)
    Zip::ZipFile.open(filepath) do |zip_file|
      zip_file.each do |f|
        content = zip_file.read(f)
        filename = basename + '/' + f.name
        find_or_create_by_content(content, kind: kind, filename: f.name, created_at: f.time)
      end
    end
  end

  # оверрайд активрекордного метода, для скорости
  def self.find_or_create_by_content(content, attrs)
    md5 = Digest::MD5.hexdigest(content)
    find_or_create_by_md5(md5, attrs.merge(content: content))
  end

  has_and_belongs_to_many :tickets
  has_and_belongs_to_many :payments

  validates :content, :presence => true
  before_save :compute_md5

  cattr_accessor :logger do
    Rails.logger
  end

  def compute_md5
    self.md5 = Digest::MD5.hexdigest(content) if content
    true
  end

  # пока без волшебства. не выбираем парсер по типу
  def parser
    Parsers::Alfabank.new(content, filename)
  end

  def parse
    parser.parse
  end

  def process!
    parse.each do |row|
      kind, pan, amount, commission, charged_on = row.values_at(:kind, :pan, :amount, :commission, :charged_on)

      klass = Payment.select_class(:payture, kind)
      condition = klass.by_pan(row[:pan]).secured.where(price: row[:price])
      if condition.count > 1
        logger.warn "several payments are matching for for pan: #{pan}, amount: #{amount}, charged_on: #{charged_on}"
        next
      end
      payment = condition.first
      if payment
        logger.debug "found Payment##{payment.id}"
        #self.payments << payment
      else
        logger.warn "not found any payment for pan: #{pan}, amount: #{amount}, charged_on: #{charged_on}"
      end
    end
  end

end
