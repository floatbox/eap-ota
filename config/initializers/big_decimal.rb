# попытка сделать BigDecimal более удобным для записи денежных сумм
class BigDecimal
  def inspect
    fracpart = abs.frac.to_s('F')
    if fracpart == '0.0'
      fix.to_s('F').sub('.0','')
    elsif fracpart.size == 3
      to_s('F')+'0'
    else
      to_s('F')
    end
  end
end
