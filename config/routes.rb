# encoding: utf-8
Eviterra::Application.routes.draw do

  match 'pricer' => 'pricer#pricer', :as => :pricer
  match 'calendar' => 'pricer#calendar', :as => :calendar
  match 'pricer/validate' => 'pricer#validate', :as => :pricer_validate

  match 'api/search(.:format)' => 'pricer#api'
  match 'api/redirection(.:format)' => 'booking#api_redirect'
  match 'api/booking/:query_key' => 'booking#api_booking', :via => :get, :as => :api_booking
  match 'api/rambler_booking(.:format)' => 'booking#api_rambler_booking', :via => :get, :as => :api_rambler_booking
  match 'api/form' => 'booking#api_form'

  match 'booking' => 'booking#index', :as => :booking
  match 'hot_offers' => 'pricer#hot_offers', :as => :hot_offers
  match 'booking/form' => 'booking#form', :as => :booking_form
  post 'booking/pay' => 'booking#pay', :as => :booking_pay
  # FIXME сделать POST однажды
  match 'booking/preliminary_booking' => 'booking#preliminary_booking', :as => :preliminary_booking
  match '/confirm_3ds/(:order_id)' => 'booking#confirm_3ds', :as => :confirm_3ds
  match 'order/:id' => 'PNR#show', :as => :show_order
  match 'order/:id/booked' => 'PNR#show_as_booked', :as => :show_booked_order
  match 'order/:id/ticketed' => 'PNR#show_as_ticketed', :as => :show_ticketed_order
  match 'order/:id/for_ticket/:ticket_id' => 'PNR#show_for_ticket', :as => :show_order_for_ticket
  match 'order/:id/receipt' => 'PNR#receipt', :as => :show_order_receipt
  match 'order/notice/:id' => 'PNR#show_sent_notice', :as => :show_sent_notice
  match '/pay/:code' => 'payments#edit', :via => :get, :as => :edit_payment
  match '/pay/:code' => 'payments#update', :via => :post, :as => :edit_payment

  match '/corporate/start' => 'corporate#start', :as => :start_corporate
  match '/corporate/stop' => 'corporate#stop', :as => :stop_corporate
  match '/corporate' => 'corporate#index', :as => :corporate
  match '/flight_groups/:id' => 'flight_groups#show', :as => :show_flight_group

  resources :geo_tags

  match 'complete.json' => 'complete#complete'

  match 'about' => 'about#index', :as => :about
  match 'iata' => 'about#iata', :as => :about
  match 'faq' => 'about#faq', :as => :about
  match 'agreement' => 'about#agreement', :as => :about
  match 'contacts' => 'about#contacts', :as => :about
  match 'about/:action' => 'about', :as => :about

  match "geo" => 'home#geo', :as => :geo
  match "subscribe" => 'subscription#subscribe', :as => 'subscribe'
  match "unsubscribe/:destination_id" => 'subscription#unsubscribe', :as => 'unsubscribe'
  root :to => 'home#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

