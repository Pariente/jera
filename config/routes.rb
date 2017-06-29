Rails.application.routes.draw do

  root to: 'pages#fresh'
  get 'garden' => 'pages#garden'
  get 'harvest' => 'pages#harvest'
  get 'sources' => 'sources#index', as: :sources
  get 'sources_search' => 'sources#results'
  get 'unable_to_fetch' => 'sources#unable_to_fetch'
  get 'source/:id' => 'sources#show', as: :source_show
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
    resources :recommendations, only: [:new]
  end

  get 'more_not_seen/:index' => 'entry_actions#more_not_seen', as: :more_not_seen
  get 'more_all/:index' => 'entry_actions#more_all', as: :more_all

  get 'contacts' => 'users#contacts'
  get 'contacts_search' => 'users#results'
  get 'befriend/:id' => 'friendships#ask', as: :befriend
  get 'accept_friendship/:id' => 'friendships#accept', as: :accept_friendship
  get 'refuse_friendship/:id' => 'friendships#refuse', as: :refuse_friendship

  get 'entries/:entry_id/recommend_to_friend/:receiver_id' => 'recommendations#recommend_to_friend', as: :recommend_to_friend
  get 'entries/:entry_id/recommend_to_team/:team_id' => 'recommendations#recommend_to_team', as: :recommend_to_team
  get 'recommendations_with/:id' => 'pages#contact', as: :recommendations_with

  post 'recommendation/:rec_id/respond' => 'messages#new', as: :respond

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
