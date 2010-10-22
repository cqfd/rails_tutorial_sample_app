SampleApp::Application.routes.draw do
  root :to => 'pages#home'

  resources :users
  resources :sessions, :only => [:new, :create, :destroy]
  resources :microposts, :only => [:create, :destroy]

  get 'pages/home'
  get 'pages/contact'
  get 'pages/about'
  get 'pages/help'

  match '/contact' => 'pages#contact'
  match '/about' => 'pages#about'
  match '/help' => 'pages#help'
  match '/signup' => 'users#new'
  match '/signin' => 'sessions#new'
  match '/signout' => 'sessions#destroy'
end
