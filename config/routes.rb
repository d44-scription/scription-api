Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :notebooks do
        resources :notes
        resources :notables
        resources :items, only: %i[index]
        resources :characters, only: %i[index]
        resources :locations, only: %i[index]
      end
    end
  end
end
