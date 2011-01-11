Eviterra::Application.routes.draw do

  match 'pricer' => 'pricer#index', :as => :pricer
  match 'pricer/validate' => 'pricer#validate', :as => :pricer_validate

  match 'booking' => 'booking#index', :as => :booking
  match 'booking/form' => 'booking#form', :as => :booking_form
  match 'booking/pay' => 'booking#pay', :as => :booking_pay
  match 'booking/preliminary_booking' => 'booking#preliminary_booking', :as => :preliminary_booking

  resources :locations do
    get :current, :on => :collection
  end

  resources :geo_tags

  resources :pnr_form, :controller => 'PNR'

  match 'complete.json' => 'complete#complete'

  match 'about/:action' => 'about', :as => :about

  match "geo" => 'home#geo', :as => :geo
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
