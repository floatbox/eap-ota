class BookingController < ApplicationController

  filter_parameter_logging :card
  
  def preliminary_booking
    recommendation = Recommendation.check_price_and_avaliability(params[:flight_codes].split('_'), {:children => params[:children].to_i, :adults => params[:adults].to_i})
    unless recommendation
      render :json => {:success => false}
      return
    end
    recommendation.validating_carrier_iata = params[:validating_carrier]
    order_data = OrderData.new(
      :recommendation => recommendation,
      :people_count => {:children => params[:children].to_i, :adults => params[:adults].to_i, :infants => params[:infants].to_i}
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
    @order.card = Billing::CreditCard.new(params[:card])
    @order.update_attributes(params[:order])
    if @order.valid? 
      if (@order.block_money && @order.create_booking)
        render :partial => 'success', :locals => {:path => pnr_form_path(@order.pnr_number), :number => @order.pnr_number}
      elsif @order.errors[:pnr_number]
        render :json => {:global_error => 'Не удалось забронировать'}
      else
        render :json => {:payment_error => @order.card.errors[:number]}
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
