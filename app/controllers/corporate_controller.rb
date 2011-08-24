class CorporateController < ApplicationController

  def start
    session[:corporate_mode] = true
    redirect_to  '/'
  end


  def stop
    session[:corporate_mode] = nil
    redirect_to  '/'
  end

end
