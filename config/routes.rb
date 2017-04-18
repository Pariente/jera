Rails.application.routes.draw do

  root to: 'pages#fresh'
  get 'garden' => 'pages#garden'
  get 'harvest' => 'pages#harvest'
  get 'trees/top' => 'sources#top'
  get 'trees/latest' => 'sources#latest'
  get 'search_sources' => 'sources#results'
  get 'unable_to_fetch' => 'sources#unable_to_fetch'
  get 'source/:id/latest' => 'sources#show_latest', as: :source_show_latest
  get 'source/:id/harvested' => 'sources#show_harvested', as: :source_show_harvested
  get 'sources/index' => 'sources#index'

  resources :sources do
    get 'subscribe' => 'subscriptions#subscribe'
    get 'unsubscribe' => 'subscriptions#unsubscribe'
    get 'move_garden' => 'subscriptions#update'
  end

  resources :entries, only: [] do
    get 'harvest' => 'entry_actions#harvest'
    get 'unharvest' => 'entry_actions#unharvest'
    get 'mask' => 'entry_actions#mask'
    get 'unmask' => 'entry_actions#unmask'
    get 'read' => 'entry_actions#read'
    get 'unread' => 'entry_actions#unread'
  end

  get 'befriend/:id' => 'friendships#ask', as: :befriend
  get 'accept_friendship/:id' => 'friendships#accept', as: :accept_friendship
  get 'refuse_friendship/:id' => 'friendships#refuse', as: :refuse_friendship

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
