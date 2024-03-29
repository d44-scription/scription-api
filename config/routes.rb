Rails.application.routes.draw do
  scope :api, defaults: { format: :json } do
    scope :v1 do
      devise_for :users, controllers: { sessions: :sessions, registrations: :registrations },
                        path_names: { sign_in: :login, sign_out: :logout }
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: %i[show update]
      resources :notebooks do
        resources :items, only: %i[index]
        resources :characters, only: %i[index]
        resources :locations, only: %i[index]

        resources :notes do
          collection do
            get :unlinked
          end
        end

        resources :notables do
          member do
            get :notes
          end

          collection do
            get :recents
          end
        end
      end
    end
  end
end
