Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :notebooks do
        resources :notes
        resources :items, only: %i[index]
        resources :characters, only: %i[index]
        resources :locations, only: %i[index]

        resources :notables do
          member do
            get :notes
          end
        end
      end
    end
  end
end
