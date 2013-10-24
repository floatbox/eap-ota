class Admin::AmadeusController < Admin::BaseController
  def help
    @subject = params[:id]
    respond_to do |format|
      format.text {render text: amadeus_help(@subject)}
      format.html
    end
  end

  protected
  def amadeus_help(subject)
    Amadeus.booking do |a|
      a.cmd_full_help("HELP #{@subject}")
    end
  end
  helper_method :amadeus_help
end
