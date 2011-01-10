class BookingController < ApplicationController

  def preliminary_booking
    pricer_form = PricerForm.load_from_cache(params[:query_key])
    recommendation = Recommendation.check_price_and_availability(params[:flight_codes].split('_'), pricer_form, params[:validating_carrier])
    if !recommendation
      render :json => {:success => false}
      return
    end
    recommendation.validating_carrier_iata = params[:validating_carrier]
    order_data = OrderData.new(
      :recommendation => recommendation,
      :people_count => pricer_form.real_people_count,
      :variant_id => params[:variant_id]
    )
    order_data.store_to_cache
    render :json => {:success => true, :number => order_data.number}
  end
  
  def index
    @order = OrderData.get_from_cache(params[:number])
    @order.init_people
    render :partial => 'embedded'
  end
  
  def pay
    @order = OrderData.get_from_cache(params[:order][:number])
    # @order.people = params[:person_attributes].sort.map{|k, v| Person.new(v)}
    @order.people = params['person_attributes'].to_a.sort_by{|a| a[0]}.map{|k, v| Person.new(v)}
    @order.set_flight_date_for_childen_and_infants
    @order.card = Billing::CreditCard.new(params[:card])
    @order.update_attributes(params[:order])
    if @order.valid?
      if @order.create_booking
        render :partial => 'success', :locals => {:pnr_path => pnr_form_path(@order.pnr_number), :pnr_number => @order.pnr_number}
      elsif @order.errors[:pnr_number]
        render :partial => 'fail', :locals => {:errors => @order.errors[:pnr_number]}
      else
        render :partial => 'fail', :locals => {:errors => @order.card.errors[:number]}
      end
      return
    elsif !@order.card.valid?
        render :partial => 'fail', :locals => {:errors => []}
        return
    end
    render :json => {:errors => @order.errors_hash}
  end

  def valid_card
    {:number => '4111111111111112', :verification_value => '123', :month => 10, :year => 2010, :first_name => 'doesnt', :last_name => 'matter'}
  end
  helper_method :valid_card

end
