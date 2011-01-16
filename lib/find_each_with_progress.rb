# encoding: utf-8
# FIXME переделать с манкипатча на модуль с extend
# проверять идет ли вывод на tty
gem 'nex3-ruby-progressbar'
require 'progressbar'
class ActiveRecord::Base

  # относительно эффективный перебор записей в таблице
  # теперь с прогрессбаром!
  def self.find_each_with_progress(name, *args, &block)

    pbar = AdvancedProgressBar.new(name, count(*args))

    find_each(*args) do |record|
      block.call(record)
      pbar.inc
    end

    pbar.finish

  end
end

class AdvancedProgressBar < ProgressBar
  def initialize(*args)
    super
    #@title_width = 20
    @format = "%-#{@title_width}s %3d%% %s %s (%d/%d)"
    @format_arguments = [:title, :percentage, :bar, :stat, :current, :total]
  end

  def fmt_current
    @current
  end

  def fmt_total
    @total
  end
end
