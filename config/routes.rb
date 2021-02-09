Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    scope :v1 do
      devise_for :users, controllers: { sessions: :sessions },
                        path_names: { sign_in: :login }
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :user, only: %i[show, update]
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
