# encoding: utf-8
class Sirena::Request::AddRemark < Sirena::Request::Base

  attr_accessor :pnr_number, :lead_family, :remark, :type

  def initialize(pnr_number, lead_family, remark, type="5")
    @pnr_number = pnr_number
    @lead_family = lead_family
    @remark = remark
    @type = type
  end

end
