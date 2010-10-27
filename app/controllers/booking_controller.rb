class BookingController < ApplicationController

  filter_parameter_logging :card

  def index
    #@pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
    @recommendation = Recommendation.check_price_and_avaliability(params[:flight_codes].split('_'), {:children => params[:children].to_i, :adults => params[:adults].to_i})
    unless @recommendation
      render :text => '<div class="booking"><div class="empty">Не удалось сделать предварительное бронирование</div></div>'
      return
    end
    @recommendation.validating_carrier_iata = params[:validating_carrier]
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

    render :partial => 'embedded'
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
    @order.recommendation = @recommendation
    @order_id = 'rh' + @recommendation_number.to_s + Time.now.sec.to_s
    if ([@card, @order] + @people).all?(&:valid?)
      pnr_number = @order.create_booking(@recommendation, @card, @order_id, @people)
      if pnr_number
        redirect_to pnr_form_path(pnr_number)
        return
      elsif @order.errors[:pnr_number]
        render :text => 'Ошибка при создании PNR'
        return
      end
    end
    @numbers = %w{первый второй третий четвертый пятый шестой седьмой восьмой девятый}
    render :action => :index
=begin
      result = Payture.new.block(@recommendation.price_with_payment_commission, @card, :order_id => @order_id)
      if result["Success"] == "True"
        @message = "Success"
        a_session = AmadeusSession.increase_pool
        air_sfr_xml = Amadeus.soap_action('Air_SellFromRecommendation', OpenStruct.new(:segments => @variant.segments, :people_count => @people.count), a_session)
        doc = Amadeus.pnr_add_multi_elements(PNRForm.new(
          :flights => [],
          :people => @people,
          :phone => '1236767',
          :email => @order.email,
          :validating_carrier => @recommendation.validating_carrier.iata
        ), a_session)
        @order.pnr_number = doc.xpath('//r:controlNumber').to_s
        if @order.pnr_number
          Amadeus.soap_action('Fare_PricePNRWithBookingClass', nil, a_session)
          Amadeus.soap_action('Ticket_CreateTSTFromPricing', nil, a_session)
          Amadeus.pnr_add_multi_elements(PNRForm.new(:end_transact => true), a_session)
          Amadeus.soap_action('Queue_PlacePNR', OpenStruct.new(:debug => false, :number => @order.pnr_number), a_session)
          @order.save
          PnrMailer.deliver_pnr_notification(@order.email, @order.pnr_number) if @order.email
          a_session.destroy
          redirect_to pnr_form_path(@order.pnr_number)
        else
          render :text => 'Ошибка при создании PNR'
        end
      else
        @message = result["ErrCode"]
        render :text => 'Ошибка при оплате ' + @message
      end




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
