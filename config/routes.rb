Rails.application.routes.draw do
  root "home#index"

  # Solo play
  resources :solo, only: %i[new create show], param: :code, controller: "solo" do
    member do
      post :answer
      post :next
    end
  end

  # Live multiplayer: students join with a code
  get  "join",          to: "players#new",    as: :join
  post "join",          to: "players#create"
  get  "play/:code",    to: "players#show",   as: :play
  post "play/:code",    to: "players#answer", as: :play_answer

  # Live multiplayer: the teacher's screen (needs the admin password)
  resources :host, only: %i[new create show], param: :code, controller: "host" do
    member do
      post :start
      post :reveal
      post :next
    end
  end

  # Leaderboard
  get "scores", to: "scores#index", as: :scores

  # Admin: questions and scores
  namespace :admin do
    root "questions#index"
    resources :questions, except: :show do
      member { patch :toggle }
    end
    resource :scores, only: :destroy
    resources :games, only: :destroy, param: :code
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
