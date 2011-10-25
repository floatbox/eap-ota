# encoding: utf-8
class CorporateController < ApplicationController

  def start
    session[:corporate_mode] = true
    cookies.delete :searches
    redirect_to  '/'
  end


  def stop
    session[:corporate_mode] = nil
    cookies.delete :searches
    redirect_to  '/'
  end

end
