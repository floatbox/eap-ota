# encoding: utf-8
Eviterra::Application.routes.draw do

  match 'pricer' => 'pricer#pricer', :as => :pricer
  match 'calendar' => 'pricer#calendar', :as => :calendar
  match 'pricer/validate' => 'pricer#validate', :as => :pricer_validate
  match 'pricer/pricer_benchmark' => 'pricer#pricer_benchmark', :as => :pricer_pricer_benchmark

  # in development: use 'api.lvh.me:3000' or modify your /etc/hosts
  constraints subdomain: 'api' do
    root to: 'api_home#index'
    match 'avia/v1/variants(.:format)' => 'pricer#api', :format => :xml
    match 'avia/v1/searches' => 'booking#api_redirect'
    match 'partner/v1/orders(.:format)' => 'api_order_stats#index', :format => :json
    match '*anything' => redirect('/')
  end

  match 'api/search(.:format)' => 'pricer#api', :format => :xml
  match 'api/redirection(.:format)' => 'booking#api_redirect'
  match 'api/booking/:query_key(.:format)' => 'booking#api_booking', :via => :get
  match 'api/rambler_booking(.:format)' => 'booking#api_rambler_booking', :via => :get, :format => :xml, :as => :api_rambler_booking
  match 'api/form' => 'booking#api_form'
  match 'api/order_stats' => 'api_order_stats#index'

  match 'booking' => 'booking#index', :as => :booking
  match 'hot_offers' => 'pricer#hot_offers', :as => :hot_offers
  match 'price_map' => 'pricer#price_map', :as => :price_map
  match 'booking/form' => 'booking#form', :as => :booking_form
  post 'booking/recalculate_price' => 'booking#recalculate_price', :as => :booking_recalculate_price
  post 'booking/pay' => 'booking#pay', :as => :booking_pay
  # FIXME сделать POST однажды
  match 'booking/preliminary_booking' => 'booking#preliminary_booking', :as => :preliminary_booking
  post 'confirm_3ds' => 'booking#confirm_3ds', :as => :confirm_3ds
  match 'order/:id' => 'PNR#show', :as => :show_order
  match 'notice/:id' => 'PNR#show_notice', :as => :show_notice
  match 'order/:id/booked' => 'PNR#show_as_booked', :as => :show_booked_order
  match 'order/:id/order' => 'PNR#show_as_order', :as => :show_order_order
  match 'order/:id/ticketed' => 'PNR#show_as_ticketed', :as => :show_ticketed_order
  match 'order/:id/for_ticket/:ticket_id' => 'PNR#show_for_ticket', :as => :show_order_for_ticket
  match 'order/:id/receipt' => 'PNR#receipt', :as => :show_order_receipt
  match '/pay/:code' => 'payments#edit', :via => :get, :as => :edit_payment
  match '/pay/:code' => 'payments#update', :via => :post, :as => :edit_payment

  match '/corporate/start' => 'corporate#start', :as => :start_corporate
  match '/corporate/stop' => 'corporate#stop', :as => :stop_corporate
  match '/corporate' => 'corporate#index', :as => :corporate
  match '/flight_groups/:id' => 'flight_groups#show', :as => :show_flight_group
  match '/seat_map/:flight(/:booking_class)' => 'seat_map#show', :as => :show_seat_map

  resources :geo_tags

  match 'complete.json' => 'complete#complete'

  match 'about' => 'about#index', :as => :about
  match 'iata' => 'about#iata', :as => :about
  match 'faq' => 'about#faq', :as => :about
  match 'agreement' => 'about#agreement', :as => :about
  match 'agreement/old' => 'about#agreement_old', :as => :about
  match 'contacts' => 'about#contacts', :as => :about
  match 'about/:action' => 'about', :as => :about

  match "whereami" => 'home#whereami', :as => :whereami
  match "subscribe" => 'subscription#subscribe', :as => 'subscribe'
  match "unsubscribe" => 'subscription#unsubscribe', :as => 'unsubscribe'
  match "unsubscribe/:destination_id" => 'subscription#unsubscribe_by_destination', :as => 'unsubscribe_by_destination'

  match "admin/commissions/check" => 'admin/commissions#check', :as => 'check_admin_commissions'
  match "admin/commissions/table" => 'admin/commissions#table', :as => 'table_admin_commissions'
  match "admin/commissions" => 'admin/commissions#index', :as => 'admin_commissions'
  match "admin/new_hot_offers" => 'admin/hot_offers#best_of_the_week', :as => 'show_best_offers'
  match 'admin/notifications/show_sent_notice/:id' => 'admin/notifications#show_sent_notice', :as => :show_sent_notice

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

