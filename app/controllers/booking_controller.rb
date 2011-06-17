# encoding: utf-8
class BookingController < ApplicationController
  protect_from_forgery :except => :confirm_3ds

  def preliminary_booking
    @search = PricerForm.load_from_cache(params[:query_key])
    set_search_context
    recommendation = Recommendation.deserialize(params[:recommendation])
    strategy = Strategy.new( :rec => recommendation, :search => @search )
    unless strategy.check_price_and_availability
      render :json => {:success => false}
    else
      order_form = OrderForm.new(
        :recommendation => recommendation,
        :people_count => @search.real_people_count,
        :variant_id => params[:variant_id],
        :last_tkt_date => recommendation.last_tkt_date
      )
      order_form.save_to_cache
      render :json => {:success => true, :number => order_form.number}
    end
  end

  def index
    @order_form = OrderForm.load_from_cache(params[:number])
    @order_form.init_people
    render :partial => 'embedded'
  end

  def pay
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.set_flight_date_for_childen_and_infants
    @order_form.update_attributes(params[:order])
    @order_form.card = CreditCard.new(params[:card]) if @order_form.payment_type == 'card'
    strategy = Strategy.new( :rec => @order_form.recommendation, :order_form => @order_form )
    if @order_form.valid?
      if strategy.create_booking
        if @order_form.payment_type == 'card'
          payture_response = @order_form.block_money
          if payture_response.success?
            @order_form.order.money_blocked!
            logger.info "Pay: payment and booking successful"

            unless strategy.delayed_ticketing?
              logger.info "Pay: ticketing"
              unless strategy.ticket
                logger.info "Pay: ticketing failed"
                @order_form.order.unblock!
                render :partial => 'failed_booking'
                return
              end
            end
            render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order_form.pnr_number), :pnr_number => @order_form.pnr_number}
          elsif payture_response.threeds?
            logger.info "Pay: payment system requested 3D-Secure authorization"
            render :partial => 'threeds', :locals => {:order_id => @order_form.order.order_id, :payture_response => payture_response}
          else
            strategy.cancel
            msg = @order_form.card.errors[:number]
            logger.info "Pay: payment failed with error message #{msg}"
            render :partial => 'failed_payment'
          end
        else
        #  @order.order.send_email
          logger.info "Pay: booking successful, payment: cash"
          render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order_form.pnr_number), :pnr_number => @order_form.pnr_number}
        end
      elsif msg = @order_form.errors[:pnr_number]
        logger.info "Pay: booking failed with error message #{msg}"
        render :partial => 'failed_booking'
      else
        logger.info "Pay: booking failed misteriously not giving an error message"
      end
      return
    end
    logger.info "Pay: invalid order"
    render :json => {:errors => @order_form.errors_hash}
  end

  def confirm_3ds
    payment_id = params[:order_id].match(/\d+$/)[0]
    pa_res = params['PaRes']
    md = params['MD']
    @payment = Payment.find_by_threeds_key(md)
    @order = @payment.order if @payment
    # FIXME сделать более внятное и понятное пользователю поведение
    if @order && pa_res && md && (@order.payment_status == 'not blocked' || @order.payment_status == 'new') && @order.confirm_3ds(pa_res, md)
      @order.money_blocked!
      strategy = Strategy.new(:order => @order)

      unless strategy.delayed_ticketing?
        logger.info "Pay: ticketing"
        unless strategy.ticket
          logger.info "Pay: ticketing failed"
          @error_message = 'Не удалось выписать билет'
          @order.unblock!
        end
      end
    elsif ['blocked', 'charged'].include? @order.payment_status
    else
      logger.info "Pay: problem confirming 3ds"
      @error_message = 'Не удалось оплатить билет'
    end
  end

end

