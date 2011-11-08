# encoding: utf-8
class BookingController < ApplicationController
  protect_from_forgery :except => :confirm_3ds

  def preliminary_booking
    @search = PricerForm.load_from_cache(params[:query_key])
    set_search_context_for_airbrake
    recommendation = Recommendation.deserialize(params[:recommendation])
    strategy = Strategy.new( :rec => recommendation, :search => @search )
    unless strategy.check_price_and_availability
      render :json => {:success => false}
    else
      order_form = OrderForm.new(
        :recommendation => recommendation,
        :people_count => @search.real_people_count,
        :variant_id => params[:variant_id],
        :query_key => @search.query_key,
        :partner => @search.partner
      )
      order_form.save_to_cache
      render :json => {:success => true, :number => order_form.number}
    end
  end

  def api_booking
    @query_key = params[:query_key]
    @search = PricerForm.load_from_cache(params[:query_key])
    save_partner if @partner = @search.partner
    render 'variant'
  end

  def api_manual_booking

    cabin = params[:request][:cls]
    if cabin == 'P'|| cabin == 'B'
      cabin = 'C'
    elsif cabin == 'E' || cabin == 'A'
      cabin = 'Y'
    end
    date1 = PricerForm.convert_api_date(params[:request][:dir])
    date2 = PricerForm.convert_api_date(params[:request][:ret])
    pricer_form_hash = {
        :from => params[:request][:src],
        :to => params[:request][:dst],
        :date1 => date1,
        :date2 => date2,
        :adults => params[:request][:adt].to_i,
        :children => params[:request][:cnn].to_i,
        :infants => params[:request][:inf].to_i,
        :cabin => cabin
    }
    @pricer_form = PricerForm.simple(pricer_form_hash)

    segments = ( params[:response][:dir] + params[:response][:ret] ).collect do |segment|
      Segment.new(:flights =>
        [Flight.new(
          :operating_carrier_iata => segment[:oa],
          :marketing_carrier_iata => segment[:ma],
          :flight_number => segment[:n],
          :booking_class => segment[:bcl],
          :cabin => segment[:cls],
          :departure_iata => params[:request][:src],
          :arrival_iata => params[:request][:dst],
          :departure_date => date1 )])
    end
    variants = Variant.new(:segments =>segments)
    booking_classes, cabins = segments.each do |segment|
      booking_classes = segment.flights.collect(&:booking_class)
      cabins = segment.flights.collect(&:cabin)
      break booking_classes, cabins
    end
    recommendation = Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => params[:response][:va],
      :booking_classes => booking_classes,
      :cabins => cabins,
      :variants => [variants]
    )
    recommendation = recommendation.serialize
    if @pricer_form.valid?
      @pricer_form.save_to_cache
      redirect_to :action => 'preliminary_booking', :query_key => @pricer_form.query_key, :recommendation => recommendation
    else
      redirect_to '/'
    end
  end

  def api_redirect
    @search = PricerForm.simple( params.slice( :from, :to, :date1, :date2, :adults, :children, :infants, :seated_infants, :cabin, :partner ))
    save_partner if @partner = @search.partner
    if @search.valid?
      @search.save_to_cache
      redirect_to "/##{@search.query_key}"
    else
      redirect_to '/'
    end
  end

  def api_form
    render 'api/form'
  end

  def index
    @order_form = OrderForm.load_from_cache(params[:number])
    @order_form.init_people
    @search = PricerForm.load_from_cache(@order_form.query_key)
    render :partial => corporate_mode? ? 'corporate' : 'embedded'
  end

  def pay
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.update_attributes(params[:order])
    @order_form.card = CreditCard.new(params[:card]) if @order_form.payment_type == 'card'
    unless @order_form.valid?
      logger.info "Pay: invalid order"
      render :json => {:errors => @order_form.errors_hash}
      return
    end

    strategy = Strategy.new( :rec => @order_form.recommendation, :order_form => @order_form )

    unless strategy.create_booking
      render :partial => 'failed_booking'
      return
    end

    unless @order_form.payment_type == 'card'
      logger.info "Pay: booking successful, payment: cash"
      render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order_form.pnr_number), :pnr_number => @order_form.pnr_number}
      return
    end

    payture_response = @order_form.block_money(request.remote_ip)

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
      render :partial => 'threeds', :locals => {:payture_response => payture_response}

    else # payture_response failed
      strategy.cancel
      msg = @order_form.card.errors[:number]
      logger.info "Pay: payment failed with error message #{msg}"
      render :partial => 'failed_payment'
    end
  end

  def confirm_3ds
    pa_res, md = params['PaRes'], params['MD']
    @payment = Payment.find_by_threeds_key(md)
    unless @payment
      render :status => :not_found
      return
    end

    @order = @payment.order
    if @order.ticket_status == 'canceled'
      logger.info "Pay: booking canceled"
      @error_message = :ticketing
      return
    end

    case @order.payment_status
    when 'not blocked', 'new'
      unless @order.confirm_3ds(pa_res, md)
        logger.info "Pay: problem confirming 3ds"
        @error_message = :payment
      else
        @order.money_blocked!
        strategy = Strategy.new(:order => @order)

        unless strategy.delayed_ticketing?
          logger.info "Pay: ticketing"

          unless strategy.ticket
            logger.info "Pay: ticketing failed"
            @error_message = :ticketing
            @order.unblock!
          end
        end
      end
    when 'blocked', 'charged'
      # do nothing?
    else
      logger.info "Pay: money unblocked?"
      @error_message = :ticketing
    end
  end

  private

  def save_partner
    session[:partner] = @partner
    cookies[:partner] = { :value => @partner, :expires => Time.now + 3600*24*30}
    logger.info "API::Partner::Enter: #{@partner} #{Time.now}"
  end

end

