ActionController::Routing::Routes.draw do |map|
  Typus::Routes.draw(map)

  map.pricer 'pricer', :controller => 'pricer', :action => 'index'
  map.pricer_validate 'pricer/validate', :controller => 'pricer', :action => 'validate'
  map.booking 'booking', :controller => 'booking', :action => 'index'
  map.booking_form 'booking/form', :controller => 'booking', :action => 'form'
  map.booking_pay 'booking/pay', :controller => 'booking', :action => 'pay'
  map.preliminary_booking 'booking/preliminary_booking', :controller => 'booking', :action => 'preliminary_booking'

  map.resources :locations, :collection => {:current => :get}

  map.resources :countries

  map.resources :airplanes

  map.resources :airports

  map.resources :cities

  map.resources :geo_tags
  
  map.resources :pnr_form, :controller => 'PNR'

  map.geo_flight_query 'flight_queries/geo/:location', :controller => :flight_queries, :action => :geo, :method => :get

  map.resources :flight_queries, :collection => {:default => :get, :presets => :get}

  map.resources :presets, :except => [:new, :create]

  map.connect 'complete.json', :controller => :complete, :action => :complete

  map.about 'about/:action', :controller => :about

  map.root :controller => "home"
  map.geo "geo", :controller => "home", :action => "geo"
end
