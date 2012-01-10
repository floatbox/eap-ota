# encoding: utf-8
class Admin::PaymentsController < Admin::EviterraResourceController
  include Typus::Controller::Bulk

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

  def set_bulk_action
    add_bulk_action("Charge", "bulk_charge")
  end
  private :set_bulk_action

  def bulk_charge(ids)
    ids.each { |id| @resource.find(id).charge! }
    notice = Typus::I18n.t("Tried to charge #{ids.count} entries. Probably successfully")
    redirect_to :back, :notice => notice
  end
  private :bulk_charge

end

