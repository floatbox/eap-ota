class BookingController < ApplicationController

  filter_parameter_logging :card

  def index
    #@pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
    @recommendation = Recommendation.check_price_and_avaliability(params[:flight_codes].split('_'), {:children => params[:children].to_i, :adults => params[:adults].to_i})
    unless @recommendation
      render :text => 'Не удалось сделать предварительное бронирование'
      return
    end
    @order = Order.new
    @variant = @recommendation.variants[0]
    @people = (1..(params[:adults].to_i + params[:children].to_i)).map {|n|
                Person.new
              }
    @people_count = {:adults => params[:adults].to_i, :children => params[:children].to_i}
    @card = Billing::CreditCard.new()
    @numbers = %w{первый второй третий четвертый пятый шестой седьмой восьмой девятый}
    @recommendation_number = @recommendation.hash
    Recommendation.store_to_cache(@recommendation_number, @recommendation)
  end
  

  # FIXME temporary bullshit
  def form
    @card = Billing::CreditCard.new(valid_card)
  end

  def pay
    @recommendation_number = params[:recommendation_number]
    @recommendation = Recommendation.load_from_cache(@recommendation_number)
    @variant = @recommendation.variants[0]
    @people = params['person_attributes'].to_a.sort_by{|a| a[0]}.map{|k, v| Person.new(v)}
    @card = Billing::CreditCard.new(params[:card])
    @order = Order.new(params[:order])
    @order_id = 'rh' + @recommendation_number.to_s + Time.now.sec.to_s
    if ([@card] + @people).all?(&:valid?)
      result = Payture.new.pay(@recommendation.price_with_payment_commission, @card, :order_id => @order_id)
      if result["Success"] == "True"
        @message = "Success"
      else
        @message = result["ErrCode"]
      end
      render :text => @message
    else
      @people_count = {:adults => params[:adults].to_i, :children => params[:children].to_i}
      @numbers = %w{первый второй третий четвертый пятый шестой седьмой восьмой девятый}
      render :action => :index
    end
=begin
    @order_id = params[:order_id]
    @amount = params[:amount]

    if @card.valid?
      result = Payture.new.pay(@amount, @card, :order_id => @order_id)
      if result["Success"] == "True"
        @message = "Success"
      else
        @message = result["ErrCode"]
      end
      render :form
    else
      render :form
    end
=end
  end

  def valid_card
    {:number => '4111111111111112', :verification_value => '123', :month => 10, :year => 2010, :first_name => 'doesnt', :last_name => 'matter'}
  end
  helper_method :valid_card

end
