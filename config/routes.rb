ActionController::Routing::Routes.draw do |map|
  Typus::Routes.draw(map)

  map.pricer 'pricer', :controller => 'pricer', :action => 'index'

  map.resources :locations, :collection => {:random => :get, :current => :get}

  map.resources :countries, :collection => {:random => :get}

  map.resources :airplanes

  map.resources :airlines

  map.resources :airports, :collection => {:random => :get}

  map.resources :cities, :collection => {:random => :get}

  map.resources :geo_tags
  
  map.resources :pnr_form, :controller => 'PNR'

  map.resources :offers, :collection => {:filter => :post, :grok => :post}

  map.geo_flight_query 'flight_queries/geo/:location', :controller => :flight_queries, :action => :geo, :method => :get

  map.resources :flight_queries, :collection => {:default => :get, :presets => :get}

  map.resources :presets, :except => [:new, :create]

  map.connect 'complete.json', :controller => :complete, :action => :complete
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
