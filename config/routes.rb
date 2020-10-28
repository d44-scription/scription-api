Rails.application.routes.draw do
  resources :notebooks do
    resources :notes
    resources :items
  end
end
