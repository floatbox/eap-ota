# encoding: utf-8
#
# комиссии переехали в config/commissions.rb
module Commission

  class << self

    delegate \
      :exists_for_rec?,
      :find_rule_for_rec,
      :rules,
      :carriers,
        to: :default_book

    # lazy считывание дефолтных комиссий
    def default_book
      @default_book || reload!
    end

    # перечитывает дефолтные комиссии. бонус - если в файле
    # комиссий синтаксическая ошибка, останутся действовать старые комиссии!
    def reload!(filename='config/commissions')
      Rails.logger.info('Reloading commissions')
      @default_book = Commission::Reader.new.read_file(filename)
    end

    # перечитывает комиссии, только если они не были загружены раньше
    def preload!
      default_book
    end

  end

end
