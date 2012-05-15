# encoding: utf-8
class Admin::PartnersController < Admin::EviterraResourceController
  def show_versions
    get_object
  end
end