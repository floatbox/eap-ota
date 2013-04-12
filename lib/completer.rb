# encoding: utf-8
require 'completer/transliterating'
require 'completer/old_school'
require 'completer/db_reader'

module Completer

  class << self

    MARSHAL_FILE = 'db/local/completer_v3.dat'
    def preload!
      @completers || load!
    end

    def main
      completers[:ru]
    end

    def completers
      preload!
      @completers
    end

    def localized(locale=nil)
      locale ||= I18n.locale
      completers[locale]
    end

    def regen!
      @completers = {}.with_indifferent_access
      @completers[:ru] = DbReaderRu.new(Completer::Transliterating.new).read
      @completers[:en] = DbReaderEn.new(Completer::OldSchool.new).read
      dump!
    end

    # нет никаких гарантий, что в дампе именно комплитер!
    def load!(filepath=MARSHAL_FILE)
      Rails.logger.debug "Completer: loading from cache #{filepath}"
      @completers = Marshal.load(open(filepath))
    end

    def dump!(filepath=MARSHAL_FILE)
      Rails.logger.debug "Completer: dumping to cache #{filepath}"
      open(filepath, 'w') do |f|
        Marshal.dump(@completers, f)
      end
    end

    delegate :complete, :dump, :object_from_string, :to => :main

  end

end

