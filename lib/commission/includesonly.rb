# encoding: utf-8

module Commission::Includesonly

  def includes arg1, arg2
    arg1 = arg1.split if arg1.is_a? String
    arg2 = arg2.split if arg2.is_a? String
    not (arg1 & arg2).empty?
  end

  def includes_only arg1, arg2
    arg1 = arg1.split if arg1.is_a? String
    arg2 = arg2.split if arg2.is_a? String
    (arg1 - arg2).empty?
  end
  
end
