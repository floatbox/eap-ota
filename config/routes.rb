ActionController::Routing::Routes.draw do |map|
  Typus::Routes.draw(map)

  map.pricer 'pricer', :controller => 'pricer', :action => 'index'
  map.pricer 'pricer/validate', :controller => 'pricer', :action => 'validate'

  map.resources :locations, :collection => {:random => :get, :current => :get}

  map.resources :countries, :collection => {:random => :get}

  map.resources :airplanes

  map.resources :airlines

  map.resources :airports, :collection => {:random => :get}

  map.resources :cities, :collection => {:random => :get}

  map.resources :geo_tags
  
  map.resources :pnr_form, :controller => 'PNR'

  map.geo_flight_query 'flight_queries/geo/:location', :controller => :flight_queries, :action => :geo, :method => :get

  map.resources :flight_queries, :collection => {:default => :get, :presets => :get}

  map.resources :presets, :except => [:new, :create]

  map.connect 'complete.json', :controller => :complete, :action => :complete

  map.root :controller => "home"
end
