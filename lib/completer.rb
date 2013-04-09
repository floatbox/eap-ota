# encoding: utf-8
require 'completer/old_school'
require 'completer/db_reader'

module Completer
  def self.preload!
    cached
  end

  def self.cached
    @completer ||= Completer.load
  end

  MARSHAL_FILE = 'tmp/completer_v1_ru.dat'
  def self.regen
    DbReaderRu.new(Completer::OldSchool.new).read.dump(MARSHAL_FILE)
  end

  # нет никаких гарантий, что в дампе именно комплитер!
  def self.load(filepath=MARSHAL_FILE)
    Rails.logger.debug "Completer: loading from cache #{filepath}"
    Marshal.load(open(filepath))
  end

  class << self
    delegate :complete, :dump, :object_from_string, :to => :cached
  end

end

