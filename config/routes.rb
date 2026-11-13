Rails.application.routes.draw do
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "recipes#index"

  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]
  resource :profile, only: %i[show update destroy]
  resource :password, only: :update

  resource :discover, only: :show, controller: :discover
  resources :users, only: %i[index show] do
    resource :follow, only: %i[create destroy]
    resources :followers, only: :index, controller: "users/followers"
    resources :following, only: :index, controller: "users/following"
  end

  namespace :recipes do
    resource :import, only: %i[new create]
  end
  resources :recipes do
    resources :grocery_items, only: :create, module: :recipes
    resource :like, only: %i[create destroy]
    resource :rating, only: %i[update destroy]
    resource :copy, only: :create
    resources :comments, only: %i[create destroy]
  end

  resources :planned_meals, only: %i[index new create destroy]

  resources :pantry_items, path: "pantry", only: %i[index create destroy]

  resource :grocery_list, only: :show do
    scope module: :grocery_lists do
      resources :items, only: %i[create show edit update destroy]
      resource :checked_items, only: :destroy
      resource :meal_plan, only: %i[new create] do
        resources :pantry_items, only: :create, module: :meal_plans
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
