Rails.application.routes.draw do

  root to: 'pages#fresh'
  get 'garden' => 'subscriptions#index'
  get 'harvest' => 'harvests#harvest'
  get 'results' => 'harvests#results'
  get 'sources' => 'sources#index', as: :sources
  get 'sources_search' => 'sources#results'
  get 'unable_to_fetch' => 'sources#unable_to_fetch'
  get 'source/:id' => 'sources#show', as: :source_show
  get 'source/:id/edit' => 'sources#edit', as: :source_edit
  patch 'source/:id/edit' => 'sources#update'
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

  get 'harvests/more' => 'harvests#more'
  get 'pages/more' => 'pages#more'

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

end
