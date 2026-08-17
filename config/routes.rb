Rails.application.routes.draw do
  devise_for :users, skip: :registrations

  root "home#index"

  get "/showcase/review", to: "showcase#review", as: :showcase_review

  get "/texts/:slug", to: "texts#show", as: :text
  get "/texts/:slug/columns/:column", to: "texts#column", as: :text_column
  get "/texts/:slug/columns/:column/lines/:line", to: "passages#show", as: :text_line
  get "/texts/:slug/columns/:column/lines/:line/matches", to: "passages#matches", as: :text_line_matches

  namespace :reviewer do
    resources :candidate_matches, only: %i[index show] do
      resources :review_decisions, only: :create
    end
  end

  namespace :api do
    namespace :v1 do
      resources :scrolls, only: :show, param: :slug
      resources :passages, only: :show do
        get :matches, on: :member
      end
      get :search, to: "search#index"
    end
  end

  get "/exports/:slug/epidoc.xml", to: "exports#epidoc", as: :epidoc_export
  get "/exports/:slug/graph.jsonld", to: "exports#graph", as: :graph_export
  get "/exports/:slug/matches.csv", to: "exports#matches", as: :matches_export

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
