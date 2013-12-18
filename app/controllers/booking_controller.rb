# encoding: utf-8
class BookingController < ApplicationController

  include ContextMethods
  helper_method :context #FIXME
  # FIXME надо научить аякс слать authenticity_token на :create
  protect_from_forgery :except => [:confirm_3ds, :create]
  before_filter :log_referrer, :only => [:api_redirect, :api_booking]
  before_filter :log_user_agent
  before_filter :save_partner_cookies, :only => [:create, :api_redirect]

  before_filter :set_context_partner, :set_context_deck_user
  before_filter :set_context_robot, only: [:api_booking]

  # вызывается аяксом со страницы api_booking и с морды
  # Parameters:
  #   "query_key"=>"ki1kri",
  #   "recommendation"=>"amadeus.SU.V.M.4.SU2074SVOLCA040512",
  #   "partner"=>"yandex",
  #   "marker"=>"",
  def create
    logo_url = context.partner.logo_exist? ? context.partner.logo_url : ''
    @recommendation = Recommendation.deserialize(params[:recommendation])
    @recommendation.find_commission! context: context
    @search = AviaSearch.from_code(params[:query_key])

    order_flow = OrderFlow.new(
      search: @search,
      recommendation: @recommendation,
      context: context,
      marker: marker
    )
    if order_flow.preliminary_booking_result
      @order_form = order_flow.order_form
      render :json => {
        :success => true,
        :number => @order_form.number,
        :partner_logo_url => logo_url,
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
    # оставил в таком виде, чтобы не ломалось при рендере
    # если переделаем урлы и тут - заработает
    @search = AviaSearch.from_code(params[:query_key])
    unless @search && @search.valid?
      # необходимо очистить anchor вручную
      return redirect_to '/#'
    end
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

  def api_redirect
    @search = AviaSearch.simple(params.slice(*AviaSearch::SimpleDecoder::PARAMS))
    if @search.valid?
      StatCounters.inc %W[enter.api_redirect.success]
      redirect_to "#{Conf.api.url_base}/##{@search.to_param}"
    else
      redirect_to "#{Conf.api.url_base}/"
    end
  rescue # CodeStash::NotFound, ArgumentError, etc
    redirect_to "#{Conf.api.url_base}/"
  ensure
    StatCounters.inc %W[enter.api_redirect.total]
  end

  # дебажная формочка для API
  def api_form
    render 'api/form'
  end

  def show
    @order_form = OrderForm.load_from_cache(params[:id] || params[:number])
    # Среагировать на изменение продаваемости/цены
    @order_form.recommendation.find_commission! context: context
    @order_form.init_people
    @order_form.context = context
    @search = AviaSearch.from_code(@order_form.query_key)

    if params[:iphone]
      render :partial => 'iphone'
    else
      render :partial => 'embedded'
    end

  end

  # TODO переделать роутинг, чтобы :id стал частью урла.
  def recalculate_price
    @order_form = OrderForm.load_from_cache(params[:id] || params[:order][:number])
    @order_form.recommendation.find_commission! context: context
    @order_form.context = context
    @order_form.update_attributes(params[:order])
    @order_form.valid?
    if @order_form.recommendation.allowed_booking? && @order_form.update_price_and_counts
      render :partial => 'newprice'
    else
      render :partial => 'failed_booking'
    end
  end

  # бронирование и платеж
  def update
    @order_form = OrderForm.load_from_cache(params[:id] || params[:order][:number])
    @order_form.context = context
    @order_form.update_attributes(params[:order])
    @order_form.payment.card = params[:card] if params[:card]

    order_flow = OrderFlow.new(order_form: @order_form, context: context, remote_ip: request.remote_ip)

    case order_flow.pay_result
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
      payment_response = order_flow.payment_response
      render :partial => 'threeds', :locals => {:payment => payment_response}
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
        strategy = Strategy.select(order: @order, context: context)

        if !strategy.delayed_ticketing?
          logger.info "Pay: ticketing"

          unless strategy.ticket
            StatCounters.inc %W[pay.errors.ticketing pay.errors.3ds]
            logger.info "Pay: ticketing failed"
            @error_message = :ticketing
            @order.unblock!
          end
        else
          if @order.ok_to_auto_ticket?
            AutoTicketStuff.new(order: @order).create_auto_ticket_job
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
    return if @search.segments.blank?
    Destination.get_by_search @search
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

