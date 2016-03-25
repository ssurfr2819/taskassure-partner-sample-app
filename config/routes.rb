Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  get '/display_my_locations' => 'tasks#display_my_locations'
  get '/newpopup' => 'user_locations#newpopup'
  get '/get_helpers' => 'tasks#get_helpers'
  get '/check_provider' => 'tasks#check_provider'
  get '/check_helper' => 'my_helper_lists#check_helper'

  # match 'taskassure_users/new' => 'taskassure_users#create_helper'

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :user_locations
  resources :my_helper_lists
  resources :partners, only: [:show, :edit, :update]
  resources :taskassure_users do
    collection do
      get 'new_helper'
      post 'create_helper'
    end
  end

  resources :users do
    member do
      get 'switch'
    end
  end

  resources :tasks do
    member do
      get 'map1'
      get 'copy'
      post 'copy'
      get 'delete_task'
      delete 'delete_task'
    end
  end

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end