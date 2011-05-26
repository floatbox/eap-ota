require 'yaml'

module Conf

  class SyntaxError < RuntimeError; end

  module ClassMethods
    def reload!
      config_files.each_with_object( config={} ) do |file, cfg_hash|
        begin
          yml = YAML.load_file(file)
          # пустые файлы отдаются как false
          cfg_hash.deep_merge!(yml) if yml
        rescue => e
          raise SyntaxError, "at file #{file}: #{e.class}, #{e.message}"
        end
      end
      config.each_with_object( @config = {}) do |(k,v), cfg|
        begin
          cfg.merge! k => process_node(v)
        rescue => e
          raise SyntaxError, "while merging section #{k}: #{e.class}, #{e.message}"
        end
      end
      @last_updated = last_updated
    end

    private

    def config_files
      ([Rails.root + 'config/defaults.yml', Rails.root + 'config/local.yml'] + Dir[Rails.root + 'config/local/*.yml'].to_a).select do |f|
        test(?r, f) && test(?f, f)
      end
    end

    def last_updated
      config_files.collect {|f| test(?M, f)}.max
    end

    def process_node hash
      # позволяем задать настройки для конкретного сервиса, отличные от текущего Rails.env
      # например, использовать amadeus.production настройки в rails s -e development
      env = (hash["env"] ||= Rails.env)
      # в тестовой среде не оверрайдим env
      env = hash["env"] = "test" if Rails.env.test?
      # оверрайдим дефолты 
      hash.merge!( hash[env] ) if hash[env]

      Struct.new(*hash.keys.map(&:to_sym)).new(*hash.values)
    end

    def config
      reload! unless @config
      @config
    end

    def method_missing meth
      config[meth.to_s] or raise("Config key #{meth} not defined")
    end
  end
  extend ClassMethods

  # Middleware для релоада конфига перед реквестом
  class Reloader
    def initialize(app)
      @app = app
    end

    def call(env)
      ::Conf.reload!
      @app.call(env)
    end
  end

end
