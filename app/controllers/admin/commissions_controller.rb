# encoding: utf-8
class Admin::CommissionsController < Admin::BaseController
  def index
    @commissions = Commission.all
  end
end
