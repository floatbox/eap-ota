# encoding: utf-8
class Admin::CustomersController < Admin::EviterraResourceController

  before_filter :find_customer, :only => [:cancel_confirmation]

  def cancel_confirmation
    if @customer.confirmed? || @customer.pending_confirmation?
      @customer.cancel_confirmation!
    end
    redirect_to :action => :show, :id => @customer.id
  end

  def find_customer
    @customer = Customer.find(params[:id])
  end

end
