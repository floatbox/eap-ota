# encoding: utf-8
class BookingController < ApplicationController
  include BookingEssentials
  protect_from_forgery :except => :confirm_3ds
  before_filter :log_referrer, :only => [:api_redirect, :api_booking, :rambler_booking]
  before_filter :log_user_agent

  # before_filter :save_partner_cookies, :only => [:preliminary_booking, :api_redirect]

  # вызывается аяксом со страницы api_booking и с морды
  # Parameters:
  #   "query_key"=>"ki1kri",
  #   "recommendation"=>"amadeus.SU.V.M.4.SU2074SVOLCA040512",
  #   "partner"=>"yandex",
  #   "marker"=>"",
  #   "variant_id"=>"1"
  def preliminary_booking
    @coded_search = params[:query_key]
    if preliminary_booking_result(Conf.amadeus.forbid_class_changing)
      render :json => {
        :success => true,
        :number => @order_form.number,
        :declared_price => @recommendation.declared_price
        }
    else
      render :json => {:success => false}
    end
  end

  # landing страничка для большинства партнеров (кроме момондо?)
  # Parameters:
  #   "query_key"=>"ki1kri"
  def api_booking
    @query_key = params[:query_key]
    @search = PricerForm.from_code(params[:query_key])
    #FIXME берем партнера из сохраненной PricerForm - надежно, но некрасиво
    @partner = Partner[@search.partner]
    @destination = get_destination

    StatCounters.inc %W[enter.api.success]

    if is_mobile_device? && !is_tablet_device?
      render 'variant_iphone'
    else
      render 'variant'
    end

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
    # FIXME если partner из @search не берется больше - переделать на before_filter save_partner_cookies
    track_partner(params[:partner] || @search.partner, params[:marker])
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

  # дебажная формочка для API
  def api_form
    render 'api/form'
  end

  def index
    @order_form = OrderForm.load_from_cache(params[:number])
    @order_form.init_people
    @order_form.admin_user = admin_user
    @search = PricerForm.from_code(@order_form.query_key)

    if params[:iphone]
      render :partial => 'iphone'
    elsif corporate_mode?
      render :partial => 'corporate'
    else
      render :partial => 'embedded'  
    end

  end

  def recalculate_price
    @order_form = OrderForm.load_from_cache(params[:order][:number])
    @order_form.people_attributes = params[:person_attributes]
    @order_form.admin_user = admin_user
    @order_form.valid?
    if @order_form.update_price_and_counts
      render :partial => 'newprice'
    else
      render :partial => 'failed_booking'
    end
  end

  def pay

    case pay_result
    when :forbidden_sale
      render :partial => 'forbidden_sale'
    when :new_price
      render :partial => 'newprice'
    when :failed_booking
      render :partial => 'failed_booking'
    when :invalid_data
      render :json => {:errors => @order_form.errors_hash}
    when :ok
      render :partial => 'success', :locals => {:pnr_path => show_notice_path(:id => @order_form.pnr_number), :pnr_number => @order_form.pnr_number}
    when :threeds
      render :partial => 'threeds', :locals => {:payment => @payment_response}
    when :failed_payment
      render :partial => 'failed_payment'
    end
  end

  # Payture: params['PaRes'], params['MD']
  # Payu: params['REFNO'], params['STATUS'] etc.
  # FIXME отработать отмену проведенного Payu платежа, если бронь уже снята
  # FIXME избежать возможности пересмотреть все заказы, возможно этим согрешит
  # неподписанный респонс Payu
  def confirm_3ds
    @payment = Payment.find_3ds_by_backref!(params)

    @order = @payment.order
    if @order.ticket_status == 'canceled'
      logger.info "Pay: booking canceled"
      @error_message = :ticketing
      return
    end

    case @order.payment_status
    when 'not blocked', 'new'
      unless @order.confirm_3ds!(params)
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

