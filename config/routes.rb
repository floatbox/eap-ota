# encoding: utf-8
Eviterra::Application.routes.draw do

  devise_for :deck_users, ActiveAdmin::Devise.config.merge(class_name: 'Deck::User')
  # оверрайд logout для typus
  get "deck/logout(.:format)", to: "active_admin/devise/sessions#destroy", as: "destroy_admin_session"

  devise_scope :customer do
    get    '#login' => 'profile/sessions#new', :as => :new_customer_session
    post   'profile/sign_in' => 'profile/sessions#create', :as => :customer_session
    delete 'profile/sign_out' => 'profile/sessions#destroy', :as => :destroy_customer_session
    put    'profile/confirm' => 'profile/confirmations#confirm', :as => :customer_confirm
  end

  devise_for :customers,
    :path => 'profile',
    :controllers => {
      :confirmations => 'profile/confirmations',
      :registrations => 'profile/registrations',
      :passwords => 'profile/passwords'
    },
    :skip => [:sessions]


  match 'pricer' => 'pricer#pricer', :as => :pricer
  match 'calendar' => 'pricer#calendar', :as => :calendar
  match 'pricer/validate' => 'pricer#validate', :as => :pricer_validate
  match 'pricer/pricer_benchmark' => 'pricer#pricer_benchmark', :as => :pricer_pricer_benchmark

  # in development: use 'api.lvh.me:3000' or modify your /etc/hosts
  constraints subdomain: /^api(?:\.staging)?$/ do
    root to: 'api_home#index'
    match 'status' => 'home#status'
    match 'avia/form' => 'booking#api_form'
    match 'avia/v1/variants(.:format)' => 'pricer#api', :format => :xml
    match 'avia/v1/searches' => 'booking#api_redirect'
    match 'partner/v1/orders(.:format)' => 'api_order_stats#index', :format => :json
    match '*anything' => redirect('/')
  end

  constraints subdomain: /^insurance(?:\.staging)?$/ do
    root to: 'insurance#index'
  end

  match 'api/search(.:format)' => 'api_home#gone'
  match 'api/redirection(.:format)' => 'booking#api_redirect'
  # какой-то жаваскрипт фигачит посты сюда. убрать потом
  post 'api/booking/edit' => proc { [404, {}, []] }
  match 'api/booking/:query_key(.:format)' => 'booking#api_booking', :via => :get
  match 'api/order_stats' => 'api_order_stats#index'
  match 'api/v1/preliminary_booking' => 'api_booking#preliminary_booking', :as => :api_preliminary_booking
  post 'api/v1/pay' => 'api_booking#pay', :as => :api_booking_pay

  match 'hot_offers' => 'pricer#hot_offers', :as => :hot_offers
  match 'price_map' => 'pricer#price_map', :as => :price_map
  # TODO прокинуть :id и сюда тоже
  post 'booking/recalculate_price' => 'booking#recalculate_price', :as => :booking_recalculate_price
  post 'booking/pay' => 'booking#update' # FIXME удалить
  post 'booking/:id' => 'booking#update', :as => :booking_pay
  get 'booking/preliminary_booking' => 'booking#create' # FIXME удалить
  post 'booking' => 'booking#create', :as => :preliminary_booking
  get 'booking' => 'booking#show' # FIXME удалить
  get 'booking/:id' => 'booking#show', :as => :booking
  post 'confirm_3ds' => 'booking#confirm_3ds', :as => :confirm_3ds
  match 'order/:id' => 'PNR#show', :as => :show_order
  match 'notice/:id' => 'PNR#show_notice', :as => :show_notice
  match 'order_stored/:id' => 'PNR#show_stored', :as => :show_order_stored
  match 'order/:id/booked' => 'PNR#show_as_booked', :as => :show_booked_order
  match 'order/:id/order' => 'PNR#show_as_order', :as => :show_order_order
  match 'order/:id/ticketed' => 'PNR#show_as_ticketed', :as => :show_ticketed_order
  match 'order/:id/for_ticket/:ticket_id' => 'PNR#show_for_ticket', :as => :show_order_for_ticket
  match 'order/:id/receipt' => 'PNR#receipt', :as => :show_order_receipt
  match '/pay/:code(/:gateway)' => 'payments#edit', :via => :get, :as => :edit_payment
  match '/pay/:code(/:gateway)' => 'payments#update', :via => :post, :as => :edit_payment

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
  match 'partners' => 'about#partners', :as => :about

  match 'insurance' => 'insurance#index', :as => :insurance

  match "whereami" => 'home#whereami', :as => :whereami
  match 'status' => 'home#status'
  match 'revision' => 'home#revision'
  match 'revision/pending' => 'home#pending'
  match 'revision/current' => 'home#current'
  match "subscribe" => 'subscription#subscribe', :as => 'subscribe'
  match "unsubscribe" => 'subscription#unsubscribe', :as => 'unsubscribe'
  match "unsubscribe/:destination_id" => 'subscription#unsubscribe_by_destination', :as => 'unsubscribe_by_destination'

  match "admin/commissions/mass_check" => 'admin/commissions#mass_check', :as => 'mass_check_admin_commissions'
  match "admin/commissions/check" => 'admin/commissions#check', :as => 'check_admin_commissions'
  match "admin/commissions/table" => 'admin/commissions#table', :as => 'table_admin_commissions'
  match "admin/commissions/page" => 'admin/commissions#page', :as => 'admin_commissions_page'
  match "admin/commissions" => 'admin/commissions#index', :as => 'admin_commissions'
  match "admin/new_hot_offers" => 'admin/hot_offers#best_of_the_week', :as => 'show_best_offers'
  match 'admin/notifications/show_sent_notice/:id' => 'admin/notifications#show_sent_notice', :as => :show_sent_notice
  match 'admin/reports/sales' => 'admin/reports#sales', :as => :admin_reports_sales

  match 'profile' => 'profile#index', :as => :profile
  match 'profile/itinerary/:id' => 'PNR#show_stored', :as => :profile_itinerary
  match 'profile/spyglass/:id' => 'profile#spyglass', :as => :profile_spyglass
  match 'profile/itinerary/:id/ticket/:ticket_id' => 'PNR#show_for_ticket', :as => :profile_itinerary_for_ticket
  match 'profile/orders' => 'profile#orders', :as => :profile_orders

  root :to => 'home#index'

  ActiveAdmin.routes(self)
end
