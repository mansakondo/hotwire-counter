Rails.application.routes.draw do
  root "counter#show"

  post "/increment", to: "counter#increment", as: :increment
  post "/decrement", to: "counter#decrement", as: :decrement
end
