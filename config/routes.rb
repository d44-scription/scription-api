Rails.application.routes.draw do
  resources :notebooks do
    resources :notes
    resources :notables
    resources :items, only: %i[index]
  end
end
