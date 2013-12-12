# encoding: utf-8
class Admin::PaymentsController < Admin::EviterraResourceController
  include CustomCSV
  include Typus::Controller::Bulk

  # обход проблемы #update с STI. форма возвращается не с params["payment"], а с params["payture_charge"], etc.
  # в девелопменте классы загружаются по требованию, так что мы вынуждены перечислять все названия сами.
  def get_model
    super
    @object_name = %W[payu_charge payu_refund payture_charge payture_refund cash_charge cash_refund].detect {|name| params[name].present? } || 'payment'
  end
  private :get_model

  def index
    @counter = Admin::PaymentsPresenter.new(@resource)
    super
  end

  def new
    redirect_to params.merge(:controller => 'admin/cash_charges')
  end

  def show_versions
    get_object
  end

  def payment_raw
    get_object
    render :text => @item.payment_status_raw
  end

  def charge
    get_object
    @item.charge!
    redirect_to :back
  end

  def block
    get_object
    @item.block!
    redirect_to :back
  end

  def cancel
    get_object
    @item.cancel!
    redirect_to :back
  end

  def sync_status
    get_object
    @item.sync_status!
    redirect_to :back
  end

  def whereabouts
    get_object
    location = begin
      if @item.ip
        # проверяем на наличие ip - в старых заказах его может не быть
        location_info = GeoIp.geolocation(@item.ip).slice(:country_name, :country_code, :region_name, :city)
        location_info.map{|(k, v)| "#{k}: #{v}\n"}.join('')
      else
        'ip-адрес не был сохранен по этому платежу'
      end
    rescue RestClient::BadGateway
      'Невозможно получить данные, попробуйте обновить страницу'
    end
    render text: location
  end

  rescue_from ArgumentError do |e|
    flash[:alert] = e.message
    redirect_to :back
  end

  private

  def set_bulk_action
    add_bulk_action("Charge", "bulk_charge")
  end

  def bulk_charge(ids)
    ids.each { |id| @resource.find(id).charge! }
    notice = Typus::I18n.t("Tried to charge #{ids.count} entries. Probably successfully")
    redirect_to :back, :notice => notice
  end

end

