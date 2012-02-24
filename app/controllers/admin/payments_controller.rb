# encoding: utf-8
class Admin::PaymentsController < Admin::EviterraResourceController
  include CustomCSV
  include Typus::Controller::Bulk

  # обход проблемы #update с STI. форма возвращается не с params["payment"], а с params["payture_charge"], etc.
  # в девелопменте классы загружаются по требованию, так что мы вынуждены перечислять все названия сами.
  def get_model
    super
    @object_name = %W[payture_charge payture_refund cash_charge cash_refund].detect {|name| params[name].present? } || 'payment'
  end
  private :get_model

  def new
    redirect_to params.merge(:controller => 'admin/cash_charges')
  end

  def show_versions
    get_object
  end

  def payment_raw
    get_object
    render :text => @item.payment_state_raw
  end

  def charge
    get_object
    @item.charge!
    redirect_to :back
  end

  def block
    get_object
    @item.block!
    redirect_to :back
  end

  def cancel
    get_object
    @item.cancel!
    redirect_to :back
  end

  private

  def set_bulk_action
    add_bulk_action("Charge", "bulk_charge")
  end

  def bulk_charge(ids)
    ids.each { |id| @resource.find(id).charge! }
    notice = Typus::I18n.t("Tried to charge #{ids.count} entries. Probably successfully")
    redirect_to :back, :notice => notice
  end

end

