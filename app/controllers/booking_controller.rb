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
    #logger.info "Recommendation: blank_count #{recommendation.blank_count} consolidator_markup #{recommendation.price_consolidator_markup}"
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
    logger.info "Recommendation: blank_count #{@order.recommendation.blank_count} consolidator_markup #{@order.recommendation.price_consolidator_markup}"
    @order.init_people
    render :partial => 'embedded'
  end

  def pay
    @order = OrderData.load_from_cache(params[:order][:number])
    @order.people_attributes = params[:person_attributes]
    @order.set_flight_date_for_childen_and_infants
    logger.info "Recommendation: blank_count #{@order.recommendation.blank_count} consolidator_markup #{@order.recommendation.price_consolidator_markup}"
    @order.update_attributes(params[:order])
    @order.card = CreditCard.new(params[:card]) if @order.payment_type == 'card'
    if @order.valid?
      if @order.create_booking
        if @order.payment_type == 'card'
          payture_response = @order.block_money
          if payture_response.success?
            @order.order.money_blocked!
            logger.info "Pay: payment and booking successful"

            # FIXME не выносить в кронтаск. но, может быть, внести обратно в .ticket!
            if @order.order.source == 'sirena'
              logger.info "Pay: ticketing sirena"
              unless Sirena::Adapter.approve_payment(@order.order)
                @error_message = 'Не удалось выписать билет'
                @order.order.unblock!
                @order.order.cancel!
              end
              # сейчас это делает approve payment
              # @order.order.ticket!
            end
            if @error_message
              render :partial => 'failed_booking', :locals => {:errors => @error_message}
            else
              render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order.pnr_number), :pnr_number => @order.pnr_number}
            end
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
    pa_res = params['PaRes']
    md = params['MD']
    @payment = Payment.find_by_threeds_key(md)
    @order = @payment.order if @payment
    # FIXME сделать более внятное и понятное пользователю поведение
    if @order && pa_res && md && (@order.payment_status == 'not blocked' || @order.payment_status == 'new') && @order.confirm_3ds(pa_res, md)
      @order.money_blocked!
      # FIXME не выносить в кронтаск. но, может быть, внести обратно в .ticket!
      if @order.source == 'sirena'
        logger.info "Pay: ticketing sirena"
        unless Sirena::Adapter.approve_payment(@order)
          @error_message = 'Не удалось выписать билет'
          @order.unblock!
          @order.cancel!
        end
        # сейчас это делает approve payment
        # @order.order.ticket!
      end
    elsif ['blocked', 'charged'].include? @order.payment_status
    else
      logger.info "Pay: payment and booking successful"
      @error_message = 'Не удалось оплатить билет'
    end
  end

end

