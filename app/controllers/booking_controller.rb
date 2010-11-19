class BookingController < ApplicationController

  filter_parameter_logging :card
  
  def preliminary_booking
    pricer_form = Rails.cache.read('pricer_form' + params[:query_key])
    recommendation = Recommendation.check_price_and_avaliability(params[:flight_codes].split('_'), pricer_form)
    if !recommendation || (recommendation.price_total != params[:total_price].to_i)
      render :json => {:success => false}
      return
    end
    recommendation.validating_carrier_iata = params[:validating_carrier]
    order_data = OrderData.new(
      :recommendation => recommendation,
      :people_count => pricer_form.real_people_count
    )
    order_data.store_to_cache
    render :json => {:success => true, :number => order_data.number}
  end
  
  def index
    @order = OrderData.get_from_cache(params[:number])
    @order.init_people
    render :partial => 'embedded'
  end
  

  # FIXME temporary bullshit
  def form
    @card = Billing::CreditCard.new(valid_card)
  end

  def pay
    @order = OrderData.get_from_cache(params[:order][:number])
    @order.people = params['person_attributes'].to_a.sort_by{|a| a[0]}.map{|k, v| Person.new(v)}
    @order.set_flight_date_for_childen_and_infants
    @order.card = Billing::CreditCard.new(params[:card])
    @order.update_attributes(params[:order])
    if @order.valid? 
      if (@order.block_money && @order.create_booking)
        render :partial => 'success', :locals => {:pnr_path => pnr_form_path(@order.pnr_number), :pnr_number => @order.pnr_number}
      elsif @order.errors[:pnr_number]
        render :partial => 'fail'
      else
        render :partial => 'fail'
        #render :json => {:payment_error => @order.card.errors[:number]}
      end
      return
    end
    render :json => { :errors => @order.errors_hash}
  end

  def valid_card
    {:number => '4111111111111112', :verification_value => '123', :month => 10, :year => 2010, :first_name => 'doesnt', :last_name => 'matter'}
  end
  helper_method :valid_card

end
