Rails.application.routes.draw do
  devise_for :users
  root 'admin/products#index'
  resources :products do
    member do
      post :add_to_cart
    end
  end

  namespace :admin do
    resources :products do
      get :publish
      get :unpublish
    end
  end
end
