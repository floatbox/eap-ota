# encoding: utf-8
class BookingController < ApplicationController
  protect_from_forgery :except => :confirm_3ds

  def preliminary_booking
    @search = PricerForm.load_from_cache(params[:query_key])
    set_search_context
    if @search.form_segments[0].date_as_date < ( Time.now.hour < 17 ? Date.today + 1.days : Date.today + 2.days)
      render :json => {:success => false}
      return
    end
    recommendation = Recommendation.deserialize(params[:recommendation])
    unless recommendation.check_price_and_availability(@search)
      render :json => {:success => false}
      return
    end
    order_data = OrderData.new(
      :recommendation => recommendation,
      :people_count => @search.real_people_count,
      :variant_id => params[:variant_id],
      :last_tkt_date => recommendation.last_tkt_date
    )
    order_data.save_to_cache
    render :json => {:success => true, :number => order_data.number}
  end

  def index
    @order = OrderData.load_from_cache(params[:number])
    @order.init_people
    render :partial => 'embedded'
  end

  def pay
    @order = OrderData.load_from_cache(params[:order][:number])
    @order.people_attributes = params[:person_attributes]
    @order.set_flight_date_for_childen_and_infants
    @order.update_attributes(params[:order])
    @order.card = CreditCard.new(params[:card]) if @order.payment_type == 'card'
    if @order.valid?
      if @order.create_booking
        if @order.payment_type == 'card'
          payture_response = @order.block_money
          if payture_response.success?
            @order.order.money_blocked!
            logger.info "Pay: payment and booking successful"
            render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order.pnr_number), :pnr_number => @order.pnr_number}
          elsif payture_response.threeds?
            logger.info "Pay: payment system requested 3D-Secure authorization"
            render :partial => 'threeds', :locals => {:order_id => @order.order.order_id, :payture_response => payture_response}
          else
            @order.order.cancel!
            msg = @order.card.errors[:number]
            logger.info "Pay: payment failed with error message #{msg}"
            render :partial => 'failed_payment', :locals => {:errors => msg}
          end
        else
          @order.order.send_email
          logger.info "Pay: booking successful, payment: cash"
          render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order.pnr_number), :pnr_number => @order.pnr_number}
        end
      elsif msg = @order.errors[:pnr_number]
        logger.info "Pay: booking failed with error message #{msg}"
        render :partial => 'failed_booking', :locals => {:errors => msg}
      else
        logger.info "Pay: booking failed misteriously not giving an error message"
      end
      return
    end
    logger.info "Pay: invalid order"
    render :json => {:errors => @order.errors_hash}
  end

  def confirm_3ds
    payment_id = params[:order_id].match(/\d+$/)[0]
    @payment = Payment.find(payment_id)
    @order = @payment.order
    pa_res = params['PaRes']
    md = params['MD']
    # FIXME сделать более внятное и понятное пользователю поведение
    if @order && pa_res && md && @order.confirm_3ds(pa_res, md)
      @order.money_blocked!
      @pnr_number = @order.pnr_number
      @pnr_path = show_order_path(@order.pnr_number)
      # FIXME вынести в кронтаск
      if @order.source == 'sirena'
        Sirena::Adapter.approve_payment(@order)
        @order.ticket!
      end
    else
      @error_message = 'Не удалось оплатить билет'
    end
  end

end

