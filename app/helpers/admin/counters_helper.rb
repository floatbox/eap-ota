# encoding: utf-8
module Admin::CountersHelper

  def counter_ratio search, enter
    return '-' if search.to_f.zero?
    ratio = search.to_s + '/' + enter.to_s
    ratio = ratio + ' '  + (enter.to_f / search.to_f * 100).round(2).to_s + '%' unless search.to_f.zero?
    ratio
  end

end
