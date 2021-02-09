Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_for :users

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
