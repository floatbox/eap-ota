# encoding: utf-8
class BookingController < ApplicationController
  protect_from_forgery :except => :confirm_3ds

  def preliminary_booking
    @search = PricerForm.load_from_cache(params[:query_key])
    set_search_context
    unless TimeChecker.ok_to_sell(@search.form_segments[0].date_as_date)
      render :json => {:success => false}
      return
    end
    recommendation = Recommendation.deserialize(params[:recommendation])
    strategy = Strategy.new( :rec => recommendation, :search => @search )
    unless strategy.check_price_and_availability
      render :json => {:success => false}
      return
    end
    order_form = OrderForm.new(
      :recommendation => recommendation,
      :people_count => @search.real_people_count,
      :variant_id => params[:variant_id],
      :last_tkt_date => recommendation.last_tkt_date
    )
    order_form.save_to_cache
    render :json => {:success => true, :number => order_form.number}
  end

  def index
    @order = OrderForm.load_from_cache(params[:number])
    @order.init_people
    render :partial => 'embedded'
  end

  def pay
    @order = OrderForm.load_from_cache(params[:order][:number])
    @order.people_attributes = params[:person_attributes]
    @order.set_flight_date_for_childen_and_infants
    @order.update_attributes(params[:order])
    @order.card = CreditCard.new(params[:card]) if @order.payment_type == 'card'
    strategy = Strategy.new( :rec => @order.recommendation, :order_form => @order )
    if @order.valid?
      if strategy.create_booking
        if @order.payment_type == 'card'
          payture_response = @order.block_money
          if payture_response.success?
            @order.order.money_blocked!
            logger.info "Pay: payment and booking successful"

            # FIXME не выносить в кронтаск. но, может быть, внести обратно в .ticket!
            unless strategy.delayed_ticketing?
              logger.info "Pay: ticketing"
              # сейчас это делает Strategy
              # @order.order.ticket!
              unless strategy.ticket(@order.order)
                logger.info "Pay: ticketing failed"
                @order.order.unblock!
                # это делает Strategy
                # @order.order.cancel!
                render :partial => 'failed_booking', :locals => {:errors => 'Не удалось выписать билет'}
                return
              end
            end
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
          # FIXME WTF не асинхронно?
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
    pa_res = params['PaRes']
    md = params['MD']
    @payment = Payment.find_by_threeds_key(md)
    @order = @payment.order if @payment
    # FIXME сделать более внятное и понятное пользователю поведение
    if @order && pa_res && md && (@order.payment_status == 'not blocked' || @order.payment_status == 'new') && @order.confirm_3ds(pa_res, md)
      @order.money_blocked!
      strategy = Strategy.new(:source => @order.source)
      unless strategy.delayed_ticketing?
        logger.info "Pay: ticketing"
        # сейчас это делает Strategy
        # @order.order.ticket!
        unless strategy.ticket(@order)
          logger.info "Pay: ticketing failed"
          @error_message = 'Не удалось выписать билет'
          @order.unblock!
          # это делает Strategy
          # @order.cancel!
        end
      end
    elsif ['blocked', 'charged'].include? @order.payment_status
    else
      logger.info "Pay: payment and booking successful"
      @error_message = 'Не удалось оплатить билет'
    end
  end

end

