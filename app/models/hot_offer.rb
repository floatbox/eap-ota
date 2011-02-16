# encoding: utf-8
class HotOffer < ActiveRecord::Base

  def pricer_form= pricer_form
    self.description = pricer_form.human
  end
end