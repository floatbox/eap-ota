# encoding: utf-8
class BookingController < ApplicationController
  protect_from_forgery :except => :confirm_3ds
  before_filter :log_referrer, :only => [:api_redirect, :api_booking, :rambler_booking]
  before_filter :log_user_agent
  # вызывается аяксом со страницы api_booking и с морды
  # Parameters:
  #   "query_key"=>"ki1kri",
  #   "recommendation"=>"amadeus.SU.V.M.4.SU2074SVOLCA040512",
  #   "partner"=>"yandex",
  #   "marker"=>"",
  #   "variant_id"=>"1"
  def preliminary_booking

    if Conf.site.forbidden_booking
      render :json => {:success => false}
      return
    end

    @search = PricerForm.load_from_cache(params[:query_key])
    #set_search_context_for_airbrake
    recommendation = Recommendation.deserialize(params[:recommendation])
    track_partner(params[:partner], params[:marker])
    strategy = Strategy.select( :rec => recommendation, :search => @search )

    StatCounters.inc %W[enter.preliminary_booking.total]
    StatCounters.inc %W[enter.preliminary_booking.#{partner}.total] if partner

    @destination = get_destination
    StatCounters.d_inc @destination, %W[enter.api.total] if @destination
    StatCounters.d_inc @destination, %W[enter.api.#{partner}.total] if @destination && partner

    unless strategy.check_price_and_availability
      render :json => {:success => false}
    else
      order_form = OrderForm.new(
        :recommendation => recommendation,
        :people_count => @search.real_people_count,
        :variant_id => params[:variant_id],
        :query_key => @search.query_key,
        :partner => partner,
        :marker => marker
      )
      order_form.save_to_cache
      render :json => {:success => true, :number => order_form.number}

      StatCounters.inc %W[enter.preliminary_booking.success]
      StatCounters.inc %W[enter.preliminary_booking.#{partner}.success] if partner
    end
  end

  # landing страничка для большинства партнеров (кроме момондо?)
  # Parameters:
  #   "query_key"=>"ki1kri"
  def api_booking
    @query_key = params[:query_key]
    @search = PricerForm.load_from_cache(params[:query_key])
    @destination = get_destination    
    render 'variant'
    StatCounters.inc %W[enter.api.success]
  ensure
    StatCounters.inc %W[enter.api.total]
  end

  def api_rambler_booking
    uri = RamblerApi.redirecting_uri params
    StatCounters.inc %W[enter.rambler_cache.success]
    redirect_to uri

  # FIXME можно указать :formats => [:xml], но я задал дефолтный формат в роутинге
  rescue IataStash::NotFound => iata_error
    render 'api/rambler_failure', :status => :not_found, :locals => { :message => iata_error.message }
  rescue ArgumentError => argument_error
    render 'api/rambler_failure', :status => :bad_request, :locals => { :message => argument_error.class }
  ensure
    StatCounters.inc %W[enter.rambler_cache.total]
  end

  def api_redirect
    @search = PricerForm.simple(params.slice( :from, :to, :date1, :date2, :adults, :children, :infants, :seated_infants, :cabin, :partner ))
    track_partner(params[:partner] || @search.partner)
    if @search.valid?
      @search.save_to_cache
      StatCounters.inc %W[enter.api_redirect.success]
      redirect_to "#{Conf.api.url_base}/##{@search.query_key}"
    else
      redirect_to "#{Conf.api.url_base}/"
    end
  rescue # IataStash::NotFound, ArgumentError, etc
    redirect_to "#{Conf.api.url_base}/"
  ensure
    StatCounters.inc %W[enter.api_redirect.total]
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
    if Conf.site.forbidden_sale
      StatCounters.inc %W[pay.errors.forbidden]
      render :partial => 'forbidden_sale'
      return
    end
    
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.update_attributes(params[:order])
    @order_form.card = CreditCard.new(params[:card]) if @order_form.payment_type == 'card'
    unless @order_form.valid?
      StatCounters.inc %W[pay.errors.form]
      logger.info "Pay: invalid order: #{@order_form.errors_hash.inspect}"
      render :json => {:errors => @order_form.errors_hash}
      return
    end

    strategy = Strategy.select( :rec => @order_form.recommendation, :order_form => @order_form )
    booking_status = strategy.create_booking

    if booking_status == :failed
      StatCounters.inc %W[pay.errors.booking]
      render :partial => 'failed_booking'
      return
    elsif booking_status == :price_changed
      render :partial => 'newprice'
      return
    end

    unless @order_form.payment_type == 'card'
      StatCounters.inc %W[pay.success.total pay.success.cash]
      logger.info "Pay: booking successful, payment: cash"
      render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order_form.pnr_number), :pnr_number => @order_form.pnr_number}
      return
    end

    payture_response = @order_form.block_money(request.remote_ip)

    if payture_response.success?
      logger.info "Pay: payment and booking successful"

      unless strategy.delayed_ticketing?
        logger.info "Pay: ticketing"
        unless strategy.ticket
          StatCounters.inc %W[pay.errors.ticketing]
          logger.info "Pay: ticketing failed"
          @order_form.order.unblock!
          render :partial => 'failed_booking'
          return
        end
      end
      StatCounters.inc %W[pay.success.total pay.success.card]
      render :partial => 'success', :locals => {:pnr_path => show_order_path(:id => @order_form.pnr_number), :pnr_number => @order_form.pnr_number}

    elsif payture_response.threeds?
      StatCounters.inc %W[pay.3ds.requests]
      logger.info "Pay: payment system requested 3D-Secure authorization"
      render :partial => 'threeds', :locals => {:payture_response => payture_response}

    else # payture_response failed
      strategy.cancel
      msg = @order_form.card.errors[:number]
      StatCounters.inc %W[pay.errors.payment]
      logger.info "Pay: payment failed with error message #{msg}"
      render :partial => 'failed_payment'
    end
  ensure
    StatCounters.inc %W[pay.total]
  end

  def confirm_3ds
    pa_res, md = params['PaRes'], params['MD']
    @payment = PaytureCharge.find_by_threeds_key!(md.presence || 'no key given')

    @order = @payment.order
    if @order.ticket_status == 'canceled'
      logger.info "Pay: booking canceled"
      @error_message = :ticketing
      return
    end

    case @order.payment_status
    when 'not blocked', 'new'
      unless @order.confirm_3ds(pa_res, md)
        StatCounters.inc %W[pay.errors.payment pay.errors.3ds pay.errors.3ds_payment]
        logger.info "Pay: problem confirming 3ds"
        @error_message = :payment
      else
        strategy = Strategy.select(:order => @order)

        unless strategy.delayed_ticketing?
          logger.info "Pay: ticketing"

          unless strategy.ticket
            StatCounters.inc %W[pay.errors.ticketing pay.errors.3ds]
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
  ensure
    StatCounters.inc %W[pay.total pay.3ds.confirmations]
  end

  def get_destination
    return if !@search.segments
    segment = @search.segments[0]
    return if ([segment.to_as_object.class, segment.from_as_object.class] - [City, Airport]).present? || @search.complex_route?
    to = segment.to_as_object.class == Airport ? segment.to_as_object.city : segment.to_as_object
    from = segment.from_as_object.class == Airport ? segment.from_as_object.city : segment.from_as_object
    Destination.find_or_create_by(:from_iata => from.iata, :to_iata => to.iata , :rt => @search.rt)
  end

  def log_referrer
    if request.referrer && (URI(request.referrer).host != request.host)
      logger.info "Referrer: #{URI(request.referrer).host}"
    end
  # приходят черти откуда.
  rescue # URI::InvalidURIError
    logger.info "Referrer not parsed: #{request.referrer}"
  end
end

