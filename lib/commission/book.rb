# encoding: utf-8
class Commission::Book
  # объекты-контейнеры для набора комиссий,
  # умеют подбирать комиссию по рекомендации
  attr_accessor :commissions

  def initialize
    @commissions = {}
  end

  def register commission
    carrier = commission.carrier
    commissions[carrier] ||= []
    commission.number = commissions[carrier].size + 1
    if commission.important
      commissions[carrier].unshift commission
    else
      commissions[carrier].push commission
    end
    commission
  end

  # Inspection
  ############

  def all_for(recommendation)
    for_carrier(recommendation.validating_carrier_iata) || []
  end

  def exists_for?(recommendation)
    for_carrier(recommendation.validating_carrier_iata).present?
  end

  def for_carrier(validating_carrier_iata)
    commissions[validating_carrier_iata]
  end

  def all
    commissions.values.flatten.sort_by {|c| c.source.to_i }
  end

  def all_carriers
    commissions.keys.uniq
  end

  def stats
    puts "#{commissions.keys.size} carriers"
    puts "#{commissions.values.sum(&:size)} rules total"
    puts "#{commissions.values.every.select(&:disabled?).sum(&:size)} rules disabled"
    puts "#{commissions.values.every.select(&:not_implemented).sum(&:size)} of which not implemented"
    disabled, enabled = commissions.keys.partition {|iata| commissions[iata].all?(&:disabled?)}
    puts "enabled #{enabled.size}: #{enabled.sort.join(' ')}"
    puts "disabled #{disabled.size}: #{disabled.sort.join(' ')}"
  end

  # Recommendation finders
  ########################

  def find_for(recommendation)
    commission = all_for(recommendation).find do |c|
      c.applicable?(recommendation)
    end
    return unless commission
    return if commission.disabled?
    commission
  end

  def all_with_reasons_for(recommendation)
    found = nil
    all_for(recommendation).map do |c|
      reason = c.turndown_reason(recommendation)
      status =
        if !found && reason
          :fail
        elsif !found && !reason
          :success
        else
          :skipped
        end
      found = c unless reason
      [c, status, reason]
    end
  end
end
