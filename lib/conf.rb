require 'yaml'

module Conf

  module ClassMethods
    def reload!
      config_files.each_with_object( config={} ) do |file, cfg_hash|
        yml = YAML.load_file(file)
        # сплошные комментарии отдаются как false
        cfg_hash.deep_merge!(yml) if yml
      end
      config.each_with_object( @config = {}) do |(k,v), cfg|
        cfg.merge! k => process_node(v)
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
      # TODO запретить оверрайд в Rails.env.test?
      env = (hash["env"] ||= Rails.env)
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

end
